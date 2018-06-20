package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"os"
	"regexp"
	"strconv"
	"strings"
	"time"

	"github.com/hypebeast/go-osc/osc"
)

var stdinline string
var clipline string
var mode byte
var modes = "wn"

type Block struct {
	text   string `json:full_text`
	markup string `json:markup`
}

func main() {
	mode = byte('w')
	reload := make(chan bool)
	go poll_stdin(reload)
	go open_osc_server(reload)

	init_json()
	update_status()
	for {
		go func(reload chan bool) {
			time.Sleep(60 * time.Second)
			reload <- true
		}(reload)
		<-reload
		update_status()
	}
}

func init_json() {
	fmt.Println("{ \"version\": 1 }")
	fmt.Println("[")
	fmt.Println("[]")
}

func update_status() {
	var items []string
	if mode == 'w' {
		items = []string{stdinline, info_battery(), info_memusage(), info_date()}
	}
	if mode == 'n' {
		items = []string{stdinline, info_battery(), info_memusage()}
	}

	type JsonStruct struct {
		Text   string `json:"full_text"`
		Markup string `json:"markup"`
	}

	line := strings.Join(items, " | ")
	asJson, _ := json.Marshal(&JsonStruct{Text: line, Markup: "pango"})
	fmt.Println(strings.Join(
		[]string{",[", string(asJson), "]"},
		"",
	))
}

func span(str, prop, value string) string {
	return strings.Join([]string{"<span ", prop, "='", value, "'>", str, "</span>"}, "")
}

func bg(str, color string) string {
	return span(str, "background", color)
}

func fg(str, color string) string {
	return span(str, "color", color)
}

func poll_stdin(reload chan bool) {
	in := bufio.NewReader(os.Stdin)
	for {
		in, _, err := in.ReadLine()
		if err != nil {
			fmt.Println("Stdin error:", err)
		}
		new := strings.Replace(strings.TrimSpace(string(in)), " - VIM", "", -1)

		if new != stdinline {
			stdinline = new
			reload <- true
		}
	}
}

func file_read(filepath string) string {
	dat, e := ioutil.ReadFile(filepath)
	warn(e)
	return string(dat)
}

func floatify(in string) float64 {
	v, e := strconv.ParseFloat(strings.TrimSpace(in), 64)
	warn(e)
	return v
}

func warn(e error) {
	if e != nil {
		panic(e)
	}
}

func info_battery() string {
	now := floatify(file_read("/sys/class/power_supply/BAT0/energy_now"))
	full := floatify(file_read("/sys/class/power_supply/BAT0/energy_full"))
	percent := (now / full) * 100
	return strings.Join([]string{fmt.Sprintf("%05.2f", percent), "%"}, "")
}

func info_date() string {
	now := time.Now()
	return now.Format(time.Kitchen)
}

func info_memusage() string {
	procInfoStr := file_read("/proc/meminfo")

	memAvailRegexp, err := regexp.Compile(`MemAvailable:[^0-9]+([0-9]+)\s*kB`)
	warn(err)
	memTotalRegexp, err := regexp.Compile(`MemTotal:[^0-9]+([0-9]+)\s*kB`)
	warn(err)
	memAvailStr := memAvailRegexp.FindStringSubmatch(procInfoStr)[1]
	memTotalStr := memTotalRegexp.FindStringSubmatch(procInfoStr)[1]
	memAvailGb := floatify(memAvailStr) / 1e6
	memTotalGb := floatify(memTotalStr) / 1e6
	memUsedGb := memTotalGb - memAvailGb

	return fmt.Sprintf("%.1fG/%.1fG", memUsedGb, memTotalGb)
}

func str_cycle(str string, char byte) byte {
	for i, c := range str {
		if char == byte(c) {
			newindex := i + 1
			if newindex >= len(str) {
				newindex = 0
			}
			return str[newindex]
		}
	}
	return str[0]
}


func maxSlice(itms []float64) float64 {
	max := 0.0
	for _, e := range itms {
		if e > max {
			max = e
		}
	}

	return max
}


func open_osc_server(reload chan bool) {
	addr := "127.0.0.1:9988"
	server := &osc.Server{Addr: addr}
	server.Handle("*", func(msg *osc.Message) {
		pieces := strings.Split(msg.Address, "/")
		pieces = pieces[1:len(pieces)]
		if pieces[0] == "mode_toggle" {
			mode = str_cycle(modes, mode)
		}
		reload <- true
	})
	server.ListenAndServe()
}
