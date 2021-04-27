<?xml version="1.0" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<svg version="1.1" width="1200" height="{{ height }}" onload="init(evt)" viewBox="0 0 1200 {{ height }}" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
<!-- ACT FLAMEGRAPH PRO DEMO -->
<!-- NOTES:  -->
<defs>
	<linearGradient id="background" y1="0" y2="1" x1="0" x2="0" >
		<stop stop-color="#eeeeee" offset="5%" />
		<stop stop-color="#eeeeb0" offset="95%" />
	</linearGradient>
</defs>
<style type="text/css">
	text { font-family:Verdana; font-size:12px; fill:rgb(0,0,0); }
	#search, #ignorecase { opacity:0.1; cursor:pointer; }
	#search:hover, #search.show, #ignorecase:hover, #ignorecase.show { opacity:1; }
	#subtitle { text-anchor:middle; font-color:rgb(160,160,160); }
	#title { text-anchor:middle; font-size:17px}
	#unzoom { cursor:pointer; }
	#frames > *:hover { stroke:black; stroke-width:0.5; cursor:pointer; }
	.hide { display:none; }
	.parent { opacity:0.5; }
</style>
<script type="text/ecmascript">
<![CDATA[
	"use strict";
	var details, searchbtn, unzoombtn, matchedtxt, svg, searching, currentSearchTerm, ignorecase, ignorecaseBtn, timesnow,timeNow_gl,timeMultiple, time_x, prefix, suffix, xmin_gl, xmax_gl;
	function init(evt) {
		timeNow_gl = 0.0;
		timeMultiple = {{ timeMultiple }};
		xmin_gl = 10.0;
		// set as width of this svg
		xmax_gl = 0.0;
		prefix = "";
		suffix = "diff: 0s";
		timesnow = document.getElementById("timesnow").firstChild;
		time_x = document.getElementsByTagName("line")[1];
		details = document.getElementById("details").firstChild;
		
		searchbtn = document.getElementById("search");
		ignorecaseBtn = document.getElementById("ignorecase");
		unzoombtn = document.getElementById("unzoom");
		matchedtxt = document.getElementById("matched");
		svg = document.getElementsByTagName("svg")[0];
		searching = 0;
		currentSearchTerm = null;
	}

	window.addEventListener("click", function(e) {
		var target = find_group(e.target);
		if (target) {
			if (target.nodeName == "a") {
				if (e.ctrlKey === false) return;
				e.preventDefault();
			}
			if (target.classList.contains("parent")) unzoom();
			zoom(target);
		}
		else if (e.target.id == "unzoom") unzoom();
		else if (e.target.id == "search") search_prompt();
		else if (e.target.id == "ignorecase") toggle_ignorecase();
	}, false)


	// mouse-over for info
	// show
	window.addEventListener("mouseover", function(e) {
		var target = find_group(e.target);
		if (target) details.nodeValue = "Function: " + g_to_text(target);
		// zoom后计算相对值
		//prefix = "timestick: "+e.clientX +"s; ";
		var newTime = 0;
		timeNow_gl = timeMultiple * ( xmin_gl - 10.0 + (xmax_gl - xmin_gl)*(e.clientX-10.0)/(svg.width.baseVal.value- 2*10.0) )
		if(timeNow_gl<0){
			timeNow_gl = 0.0;
		}
		prefix = "timestick: "+ timeNow_gl +"s; ";
		timesnow.nodeValue = prefix + suffix;
	}, false)

	// mouse-down for info    LFJLFJLFJLFJ
	// show
	window.addEventListener("mousedown", function(e) {
		if(xmax_gl===0.0){
			xmax_gl = svg.width.baseVal.value - 10.0
		}
		if(xmin_gl===0.0){
			xmin_gl = 10.0
		}
		// zoom后计算相对值
		var newTime = 0;
		timeNow_gl = timeMultiple * ( xmin_gl - 10.0 + (xmax_gl - xmin_gl)*(e.clientX-10.0)/(svg.width.baseVal.value- 2*10.0) )
		if(timeNow_gl<0){
			timeNow_gl = 0.0;
		}
		prefix = "timestick: "+ timeNow_gl +"s; ";
		var lastTimeNow_gl = timeMultiple * ( xmin_gl - 10.0 + (xmax_gl - xmin_gl)*(time_x.getAttribute("x1")-10.0)/(svg.width.baseVal.value- 2*10.0) )
		suffix = "diff: "+String( timeNow_gl - lastTimeNow_gl )+"s";
		timesnow.nodeValue = prefix + suffix;

		time_x.setAttribute("x1",e.clientX);
		time_x.setAttribute("x2",e.clientX);
		console.log("TimeStamp:::",e.timeStamp, "  xmin:[",xmin_gl,"] xmax[",xmax_gl,"]")
	}, false)

	// clear
	window.addEventListener("mouseout", function(e) {
		var target = find_group(e.target);
		if (target) details.nodeValue = ' ';
	}, false)

	// ctrl-F for search
	window.addEventListener("keydown",function (e) {
		if (e.keyCode === 114 || (e.ctrlKey && e.keyCode === 70)) {
			e.preventDefault();
			search_prompt();
		}
	}, false)

	// ctrl-I to toggle case-sensitive search
	window.addEventListener("keydown",function (e) {
		if (e.ctrlKey && e.keyCode === 73) {
			e.preventDefault();
			toggle_ignorecase();
		}
	}, false)

	// functions
	function find_child(node, selector) {
		var children = node.querySelectorAll(selector);
		if (children.length) return children[0];
		return;
	}
	
	function find_group(node) {
		var parent = node.parentElement;
		if (!parent) return;
		if (parent.id == "frames") return node;
		return find_group(parent);
	}

	function orig_save(e, attr, val) {
		if (e.attributes["_orig_" + attr] != undefined) return;
		if (e.attributes[attr] == undefined) return;
		if (val == undefined) val = e.attributes[attr].value;
		e.setAttribute("_orig_" + attr, val);
	}

	function orig_load(e, attr) {
		if (e.attributes["_orig_"+attr] == undefined) return;
		e.attributes[attr].value = e.attributes["_orig_" + attr].value;
		e.removeAttribute("_orig_"+attr);
	}

	function g_to_text(e) {
		var text = find_child(e, "title").firstChild.nodeValue;
		return (text)
	}

	function g_to_func(e) {
		var func = g_to_text(e);
		// if there's any manipulation we want to do to the function
		// name before it's searched, do it here before returning.
		return (func);
	}

	function update_text(e) {
		var r = find_child(e, "rect");
		var t = find_child(e, "text");
		var w = parseFloat(r.attributes.width.value) -3;
		var txt = find_child(e, "title").textContent.replace(/\([^(]*\)$/,"");
		t.attributes.x.value = parseFloat(r.attributes.x.value) + 3;

		// Smaller than this size won't fit anything
		if (w < 2 * 12 * 0.59) {
			t.textContent = "";
			return;
		}

		t.textContent = txt;
		// Fit in full text width
		if (/^ *$/.test(txt) || t.getSubStringLength(0, txt.length) < w)
			return;

		for (var x = txt.length - 2; x > 0; x--) {
			if (t.getSubStringLength(0, x + 2) <= w) {
				t.textContent = txt.substring(0, x) + "..";
				return;
			}
		}
		t.textContent = "";
	}

	// zoom
	function zoom_reset(e) {
		xmin_gl = 10.0;
		xmax_gl = svg.width.baseVal.value - 10.0;
		if (e.attributes != undefined) {
			orig_load(e, "x");
			orig_load(e, "width");
		}
		if (e.childNodes == undefined) return;
		for (var i = 0, c = e.childNodes; i < c.length; i++) {
			zoom_reset(c[i]);
		}
	}

	function zoom_child(e, x, ratio) {
		if (e.attributes != undefined) {
			if (e.attributes.x != undefined) {
				orig_save(e, "x");
				e.attributes.x.value = (parseFloat(e.attributes.x.value) - x - 10) * ratio + 10;
				if (e.tagName == "text")
					e.attributes.x.value = find_child(e.parentNode, "rect[x]").attributes.x.value + 3;
			}
			if (e.attributes.width != undefined) {
				orig_save(e, "width");
				e.attributes.width.value = parseFloat(e.attributes.width.value) * ratio;
			}
		}

		if (e.childNodes == undefined) return;
		for (var i = 0, c = e.childNodes; i < c.length; i++) {
			zoom_child(c[i], x - 10, ratio);
		}
	}

	function zoom_parent(e) {
		if (e.attributes) {
			if (e.attributes.x != undefined) {
				orig_save(e, "x");
				e.attributes.x.value = 10;
			}
			if (e.attributes.width != undefined) {
				orig_save(e, "width");
				e.attributes.width.value = parseInt(svg.width.baseVal.value) - (10 * 2);
			}
		}
		if (e.childNodes == undefined) return;
		for (var i = 0, c = e.childNodes; i < c.length; i++) {
			zoom_parent(c[i]);
		}
	}

	function zoom(node) {
		var attr = find_child(node, "rect").attributes;
		var width = parseFloat(attr.width.value);
		var xmin = parseFloat(attr.x.value);
		var xmax = parseFloat(xmin + width);
		var ymin = parseFloat(attr.y.value);
		var ratio = (svg.width.baseVal.value - 2 * 10) / width;
		xmin_gl = xmin+10.0;
		xmax_gl = xmax+10.0;

		// XXX: Workaround for JavaScript float issues (fix me)
		var fudge = 0.0001;

		unzoombtn.classList.remove("hide");

		var el = document.getElementById("frames").children;
		for (var i = 0; i < el.length; i++) {
			var e = el[i];
			var a = find_child(e, "rect").attributes;
			var ex = parseFloat(a.x.value);
			var ew = parseFloat(a.width.value);
			var upstack;
			// Is it an ancestor
			if (0 == 0) {
				upstack = parseFloat(a.y.value) > ymin;
			} else {
				upstack = parseFloat(a.y.value) < ymin;
			}
			if (upstack) {
				// Direct ancestor
				if (ex <= xmin && (ex+ew+fudge) >= xmax) {
					e.classList.add("parent");
					zoom_parent(e);
					update_text(e);
				}
				// not in current path
				else
					e.classList.add("hide");
			}
			// Children maybe
			else {
				// no common path
				if (ex < xmin || ex + fudge >= xmax) {
					e.classList.add("hide");
				}
				else {
					zoom_child(e, xmin, ratio);
					update_text(e);
				}
			}
		}
		search();
	}

	function unzoom() {
		unzoombtn.classList.add("hide");
		var el = document.getElementById("frames").children;
		for(var i = 0; i < el.length; i++) {
			el[i].classList.remove("parent");
			el[i].classList.remove("hide");
			zoom_reset(el[i]);
			update_text(el[i]);
		}
		search();
	}

	// search
	function toggle_ignorecase() {
		ignorecase = !ignorecase;
		if (ignorecase) {
			ignorecaseBtn.classList.add("show");
		} else {
			ignorecaseBtn.classList.remove("show");
		}
		reset_search();
		search();
	}

	function reset_search() {
		var el = document.querySelectorAll("#frames rect");
		for (var i = 0; i < el.length; i++) {
			orig_load(el[i], "fill")
		}
	}

	function search_prompt() {
		if (!searching) {
			var term = prompt("Enter a search term (regexp " +
			    "allowed, eg: ^ext4_)"
			    + (ignorecase ? ", ignoring case" : "")
			    + "\nPress Ctrl-i to toggle case sensitivity", "");
			if (term != null) {
				currentSearchTerm = term;
				search();
			}
		} else {
			reset_search();
			searching = 0;
			currentSearchTerm = null;
			searchbtn.classList.remove("show");
			searchbtn.firstChild.nodeValue = "Search"
			matchedtxt.classList.add("hide");
			matchedtxt.firstChild.nodeValue = ""
		}
	}

	function search(term) {
		if (currentSearchTerm === null) return;
		var term = currentSearchTerm;

		var re = new RegExp(term, ignorecase ? 'i' : '');
		var el = document.getElementById("frames").children;
		var matches = new Object();
		var maxwidth = 0;
		for (var i = 0; i < el.length; i++) {
			var e = el[i];
			var func = g_to_func(e);
			var rect = find_child(e, "rect");
			if (func == null || rect == null)
				continue;

			// Save max width. Only works as we have a root frame
			var w = parseFloat(rect.attributes.width.value);
			if (w > maxwidth)
				maxwidth = w;

			if (func.match(re)) {
				// highlight
				var x = parseFloat(rect.attributes.x.value);
				orig_save(rect, "fill");
				rect.attributes.fill.value = "rgb(230,0,230)";

				// remember matches
				if (matches[x] == undefined) {
					matches[x] = w;
				} else {
					if (w > matches[x]) {
						// overwrite with parent
						matches[x] = w;
					}
				}
				searching = 1;
			}
		}
		if (!searching)
			return;

		searchbtn.classList.add("show");
		searchbtn.firstChild.nodeValue = "Reset Search";

		// calculate percent matched, excluding vertical overlap
		var count = 0;
		var lastx = -1;
		var lastw = 0;
		var keys = Array();
		for (k in matches) {
			if (matches.hasOwnProperty(k))
				keys.push(k);
		}
		// sort the matched frames by their x location
		// ascending, then width descending
		keys.sort(function(a, b){
			return a - b;
		});
		// Step through frames saving only the biggest bottom-up frames
		// thanks to the sort order. This relies on the tree property
		// where children are always smaller than their parents.
		var fudge = 0.0001;	// JavaScript floating point
		for (var k in keys) {
			var x = parseFloat(keys[k]);
			var w = matches[keys[k]];
			if (x >= lastx + lastw - fudge) {
				count += w;
				lastx = x;
				lastw = w;
			}
		}
		// display matched percent
		matchedtxt.classList.remove("hide");
		var pct = 100 * count / maxwidth;
		if (pct != 100) pct = pct.toFixed(1)
		matchedtxt.firstChild.nodeValue = "Matched: " + pct + "%";
	}
]]>
</script>

<rect x="0.0" y="0" width="1200.0" height="{{ height }}" fill="url(#background)"  />
<text id="title" x="600.00" y="24" >Flame Graph Pro</text>
<text id="details" x="10.00" y="485" > </text>
<text id="unzoom" x="10.00" y="24" class="hide">Reset Zoom</text>
<text id="search" x="1090.00" y="24" >Search</text>
<text id="ignorecase" x="1174.00" y="24" >ic</text>
<text id="matched" x="1090.00" y="485" > </text>
<g id="frames">

{% for item in items -%}
<g>
<title>{{ item.title }}</title><rect x="{{ item.x }}" y="{{ item.y }}" width="{{ item.width }}" height="15.0" fill="{{item.color}}" rx="2" ry="2" />
<text  x="{{ item.x_t }}" y="{{ item.y_t }}" >{{ item.text }}</text>
</g>
{% endfor %}

</g>

<g>
<line x1="10" y1="{{ height_time_axis }}" x2="1190" y2="{{ height_time_axis }}" style="stroke:rgb(0,255,0);stroke-width:20"/>
  <text id="timesnow" x="13" y="{{ height_time_axis_plus }}" >0</text>
  
<line id="timexline" x1="0" y1="0" x2="0" y2="{{ height }}" style="stroke:rgb(0,0,0);stroke-width:0.3"/>
</g>

</svg>
