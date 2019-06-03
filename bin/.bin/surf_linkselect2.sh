#!/usr/bin/env sh
#
# surf_linkselect.sh:
#  Revision: 2 (Fri May 10 20:25:25 CDT 2019)
#
#  Usage:
#    curl g.com | surf_linkselect [SURFWINID] [PROMPT] [TAG] [LPROP] [CPROP]
#  
#  Args:
#   - SURFWINID: windowid of surf instance
#   - PROMPT:    prompt to be used for dmenu
#   - TAG:       (optional, default: a) tag to extract via xpath
#   - LPROP:     (optional, default: href) target link property on provided tag
#   - CPROP:     (optional, default: '') target property on provided tag w/
#                target content. set to '' use tag's inner contents at title
#
#  Description:
#    Given an HTML body as STDIN, extracts links via xmllint & provides list
#    to dmenu with each link paired with its associated content. Selected
#    link is then normalized based on the passed surf window's URI and the
#    result is printed to STDOUT.
#
#  Dependencies:
#    xmllint, awk, dmenu

function dump_links_with_titles() {
  TAG=$1
  LINKPROP=$2
  CONTENTPROP=$3
  # E.g. href = [hH][rR][eE][fF] , img = [iI][mM][gG]
  tag_regex=`echo $TAG | grep -o . | awk -F' ' '{print "["toupper($1) tolower($1)"]"}' | tr -d '\n'`
  linkprop_regex=`echo $LINKPROP | grep -o . | awk -F' ' '{print "["toupper($1) tolower($1)"]"}' | tr -d '\n'`
  contentprop_regex=`echo $CONTENTPROP | grep -o . | awk -F' ' '{print "["toupper($1) tolower($1)"]"}' | tr -d '\n'`

  awk '{
    input = $0;

    # Determine the link
    $0 = input;
    match($0, /\<[ ]*'$tag_regex'[^>]* '$linkprop_regex'=["]([^"]+)["]/, linkextract);
    $0 = linkextract[1];
    gsub("[ ]", "%20");
    link = $0;

    if ("'$contentprop_regex'"!="") {
      # Use specific property for the content
      $0 = input;
      match($0, /\<[ ]*'$tag_regex'[^>]* '$contentprop_regex'=["]([^"]+)["]/, titleprop);
      $0 = titleprop[1];
      title = ($0 == "" ? "None" : $0);
    } else {
      # Use inner content of the tag for the title, just strip away all tags
      $0 = input;
      gsub("<[^>]*>", "");
      gsub(/[ ]+/, " ");
      $1 = $1;
      title = ($0 == "" ? "None" : $0);
    }


    print title ": " link;
  }'
}

function link_normalize() {
  URI=$1
  awk -v uri=$URI '{
    if ($0 ~ /^https?:\/\//  || $0 ~ /^\/\/.+$/) {
      print $0;
    } else if ($0 ~/^#/) {
      gsub(/[#?][^#?]+/, "", uri);
      print uri $0;
    } else if ($0 ~/^\//) {
      split(uri, uri_parts, "/");
      print uri_parts[3] $0;
    } else {
      gsub(/[#][^#]+/, "", uri);
      uri_parts_size = split(uri, uri_parts, "/");
      delete uri_parts[uri_parts_size];
      for (v in uri_parts) {
        uri_pagestripped = uri_pagestripped uri_parts[v] "/"
      }
      print uri_pagestripped $0;
    }
  }'
}

function link_select() {
  SURF_WINDOW=$1
  DMENU_PROMPT=$2
  # Valid ideas: [a href title] [a href] [img src alt]
  TAG="${3:-a}"
  LINKPROP="${4:-href}"
  CONTENTPROP=$5

  tr -d '\n\r' |
    xmllint --html --xpath "//$TAG" - |
    dump_links_with_titles $TAG $LINKPROP $CONTENTPROP |
    sort |
    uniq |
    dmenu -p "$DMENU_PROMPT" -l 10 -i -w $SURF_WINDOW |
    awk -F' ' '{print $NF}' |
    link_normalize $(xprop -id $SURF_WINDOW _SURF_URI | cut -d '"' -f 2)
}

link_select "$1" "$2" "$3" "$4" "$5"