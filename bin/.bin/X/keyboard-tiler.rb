#!/usr/bin/ruby
# keyboard-tiler: A CLI to positions windows on the grid of your screen using xdotool
# Usage: 
# keyboard-tiler a/  (This would place the window on the bottom half of your screen)

#The Tiles you want to use for positioning, default is center of US Keyboard
$tiles = [
	[ '1', '2', '3', '4', '5', '6', '7', '8', '9', '0' ],
	[ 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p' ],
	[ 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';' ],
	[ 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/' ]
]
#Height of your window decorations, just set 0 if none
$decorationsHeight = 20

def repositionWindow(squareA, squareB, screen) 

	gridDimensions = {
		:width => $tiles[0].length,
		:height => $tiles.length
	}

	#Make sure tiles go from left top most to bottom right most
	#
	squareA, squareB = {
		:x => [squareA[:x], squareB[:x]].min,
		:y => [squareA[:y], squareB[:y]].min
	}, {
		:x => [squareA[:x], squareB[:x]].max,
		:y => [squareA[:y], squareB[:y]].max
	}

	#Calculate Height and width factor based on passed screen and gridDimensions
	heightFactor = screen[:height] / gridDimensions[:height]
	widthFactor  = screen[:width]  / gridDimensions[:width]

	#Calculate Start X and Y
	startX = screen[:offsetX] + (squareA[:x] * widthFactor)
	startY = squareA[:y] * heightFactor

	#Figure out how big to resize to
	newWidth = (squareB[:x] - squareA[:x] + 1) * widthFactor
	newHeight = (squareB[:y] - squareA[:y] + 1) * heightFactor 

	#Fire to xdotool move and resize commands
	%x[xdotool getactivewindow windowmove --sync #{startX} #{$decorationsHeight + startY}]
	%x[xdotool getactivewindow windowsize --sync #{newWidth} #{newHeight - ($decorationsHeight * 2)}]
end

def main

	#Determine Current Window Values from xwin
	xwin = %x[xwininfo -id $(xdotool getactivewindow)]
	window = {
		:x		=> xwin.scan(/Absolute upper-left X:\s+(\d+)/).join.to_i,
		:y		=> xwin.scan(/Absolute upper-left Y:\s+(\d+)/).join.to_i,
		:width	=> xwin.scan(/Width:\s+(\d+)/).join.to_i,
		:height	=> xwin.scan(/Height:\s+(\d+)/).join.to_i	
	}

	#Get the Screens Dimensions from xrandr
	screens = {}
	%x[xrandr --current].scan(/(.+) connected (\d+)x(\d+)+/).each_with_index.map do |screen, screenNumber|
		screens[screenNumber]= {
			:name		=>  screen[0],
			:width		=>  screen[1].to_i,
			:height		=>  screen[2].to_i,
			:offsetX	=> 	0
		}
	end

	#Add offset if the window's x more than the first screen's width
	if (window[:x] > screens[0][:width]) then
		screenNumber = 1
		screens[1][:offsetX] = screens[0][:width]
	else
		screenNumber = 0
	end

	#Process ARGS to get pairs on the grid
	pairs = {}
	ARGV[0].scan(/./).each_with_index do |arg, index|
		$tiles.each_with_index do |row, column|
			row.each_with_index do |cell, count|
				if (cell == arg) then
					label = (index == 0) ? :start : :end
					pairs[label] =  { :x => count, :y => column }
				end
			end
		end
	end	

	repositionWindow(pairs[:start], pairs[:end], screens[screenNumber])
end

main
