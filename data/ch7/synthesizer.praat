# function_simulator.praat
# djmw 20091015, 20091030, 20110201
# djmw 20110208 unstoppable forms

#TODO if show_sampling t -> (k-1/2)T
# make everything drawable in picture window
# background spectrum
# play with different sampling frequencies

display_one_sine = 1
display_two_sines = 0
display_one_damped_sine = 0
display_two_damped_sines = 0
display_dBFunction = 0

praatversion = 1
debug = 0
buttons = 0
first_time = 1
precision = 1e-6

space$ = " "
upArrow$ = "\^|"
upArrow_regex$ = "\\\^\|"
downArrow$ = "\_|"
downArrow_regex$ = "\\_\|"
fade_in$ = "/"
fade_out$ = "\"
left$ = "<"
right$ = ">"
up$ = "\an"
down$ = "\or"
xrange_smaller$ = ">--<"
xrange_wider$ = "<--->"
xrange_multiplier = 2
yrange_wider$ = up$
yrange_smaller$ = down$
yrange_multiplier = 2
fastForward$ = ">>"
fastBackwards$ = "<<"
label_is_procedure$ = "^^"

color_parameter$ = "Blue"
color_query_link$ = "Red"
color_normal$ = "Black"
color_clip$ = "Red"
color_fade$ = "Green"
color_reconstruction$ = "Magenta"

form_ymin$ = "-1.0"
form_ymax$ = "1.0"

if display_one_sine
	form_parameters$ = "amplitude:A frequency:f phase:\\fi"
	form_parameter_initial_values$ = "1.0 200.0 0.0"
	form_parameter_limits$ = "n n 0 n n n"
	form_function$ = "amplitude*sin(2*pi*frequency*x+phase)"
	display_variable_x_as$ = "t"
	form_xmin$ = "0.0c"
	form_xmax$ = "0.1"
endif

if display_one_damped_sine 
	form_parameters$ = "amplitude:A frequency:F damping:\\al phase:\\fi"
	form_parameter_initial_values$ = "1.0 100.0 100.0 0.0"
	form_parameter_limits$ = "n n 0 n n n"
	form_function$ = "amplitude*exp(-damping*x)*sin(2*pi*frequency*x+phase)"
	display_variable_x_as$ = "t"
	form_xmin$ = "0.0c"
	form_xmax$ = "0.1"
endif

if display_two_damped_sines
	form_parameters$ = "a_1 b_1 f_1 p1:\\fi_1 a_2 b_2 f_2 p2:\\fi_2"
	form_parameter_initial_values$ = "1.0 50.0 800.0 0 1.0 50.0 1200.0 0"
	form_parameter_limits$ = "n n 0 n n n"
	form_function$ = "a_1*exp(-pi*b_1*x)*sin(2*pi*f_1*x+p1) +a_2*exp(-pi*b_2*x)*sin(2*pi*f_2*x+p2) "
	display_variable_x_as$ = "t"
	form_xmin$ = "0.0c"
	form_xmax$ = "0.1"
endif
if display_dBFunction
	form_parameters$ = "scale"
	form_parameter_initial_values$ = "1"
	form_parameter_limits$ = "n n n n n n"
	form_function$ = "scale*log10(x/2e-5) "
	display_variable_x_as$ = "x"
	form_xmin$ = "0.001c"
	form_xmax$ = "1"
	form_ymin$ = "-80"
	form_ymax$ ="100"

endif

form_vertical_grid_lines = 5
form_horizontal_grid_lines = 3
form_background_functions$ = ""
function_draw_npoints = 1000
function_drawing_method = 1
function_drawing_method$ = "Curve"
background_functions$ = ""
vertical_grid_lines = 0
horizontal_grid_lines = 0
drawing_method1$= "Curve"
drawing_method2$ = "Poles"
drawing_method3$ = "Speckles"

spectrum_calculation = 1
spectrum_xmin = 0
spectrum_xmax = 2000
minimum_power = 0
maximum_power = 100
minimum_frequency = 0
maximum_frequency = 2000
maximum_frequency_is_Nyquist = 0
trace_frequency = 0
frequency_traced = 500

sound = 0
sound_reconstructed = 0
fade_in_time = 0.005
fade_out_time = 0.005
playable_as_sound = 0
sound_played = 0
show_clipping = 0
sound_clip_min = -1
sound_clip_max = 1
show_sampling = 0
show_reconstructed = 0
sampling_frequency = 44100
quantization_number_of_bits = 16

new_function = 1

# make 1 to draw spectrum beside the function
spectrum = 0
spectrum_background = 0
spectrum_reconstructed = 0
function_and_spectrum = 0
spectrum_ymax = 100
spectrum_ymin = 0
spectrum_query = 0

demo demoWindowTitle ("Function simulator")

@init
@buttons_draw

while demoWaitForInput()
	if demoClicked()
		@buttons_checkClickedIn
		@actions
		if not sound_played
			demo Erase all
			@buttons_draw
		endif
		sound_played = 0
	endif
endwhile

procedure actions
	selectObject: buttons
	.irow = Search column: "clicked", "1"
	if .irow > 0
		.label_id$ = object$ [buttons, .irow, "label_id"]
		.type$ =  object$ [buttons, .irow, "type"]

		@debug: "actions: clicked on " + .type$ + " " + .label_id$ + ";" 
		... + string$ (playable_as_sound) + " " + string$ (function_and_spectrum)

		if index (.type$, "parameter") > 0
			@parameter_change: .irow
		elsif .type$ = "sampling"
			@sampling_change: .irow
		elsif .type$ = "xrange" or .type$ = "yrange"
			@scale_range: .type$, .label_id$
		elsif .type$ = "function"
			@function_options
		elsif .type$ = "formula_background"
			@formula_background: .irow
		elsif .type$ = "control"
			new_function = 1
			@init
		elsif .type$ = "options"
			@options
			# next must be the last test otherwise the following tests would NOT be reachable if one
			# playable_as_sound or function_and_spectrum is on
		elsif playable_as_sound or function_and_spectrum
			if .type$ = "play"
				@play_as_sound
			elsif .type$ = "fade"
				@fade_change: .irow
			elsif .type$ = "spectrum"
				@spectrum_options
			endif
		endif
	endif
endproc

procedure sampling_change: .irow
	.label$ = object$ [buttons, .irow, "label"]
	if index (.label$, "*") = 1 or index (.label$, "/") = 1
		sampling_time = 1 / sampling_frequency
		sampling_time = sampling_time '.label$' ; *2 or /2
		sampling_frequency = 1 / sampling_time
	endif
endproc

procedure draw_sampling_frequency_label: .irow, .vpx1, .vpx2, .vpy1, .vpy2
	.sf$ = fixed$ (sampling_frequency, 0)
	@draw_sampling_label: .irow, .vpx1, .vpx2, .vpy1, .vpy2, "= " + .sf$ + " (Hz)"
endproc

procedure draw_sampling_label: .irow, .vpx1, .vpx2, .vpy1, .vpy2, .label$
	demo Select inner viewport: .vpx1, .vpx2, .vpy1, .vpy2
	demo Axes: .vpx1, .vpx2, .vpy1, .vpy2
	demo Colour: color_parameter$
	demo Draw rounded rectangle: .vpx1, .vpx2, .vpy1, .vpy2, 3
	Set string value: .irow, "label", .label$
	demo Colour: color_normal$
	demo Font size: 14
	demo Text: (.vpx1+.vpx2)/2, "Centre", (.vpy1+.vpy2)/2, "Half", .label$
	demo Colour: color_normal$
endproc

procedure draw_sampling_time_label: .irow, .vpx1, .vpx2, .vpy1, .vpy2
	.t$ = fixed$ (1.0 / sampling_frequency, 6)
	@draw_sampling_label: .irow, .vpx1, .vpx2, .vpy1, .vpy2, "= " + .t$ + " (s)"
endproc

procedure draw_quantization_nbits .irow .vpx1 .vpx2 .vpy1 .vpy2
	@draw_sampling_label: .irow, .vpx1, .vpx2, .vpy1, .vpy2, string$ (quantization_number_of_bits)
endproc

procedure formula_background: .irow
	if demoShiftKeyPressed ()
		beginPause ("Options")
		comment ("Display other function in the background")
		comment ("Any function, like for example x or sin(x) or fixed(x) or current(x)")
		text ("Background_functions", background_functions$)
		.clicked = endPause ("Cancel", "OK", 2, 1)
		if .clicked = 2
			.mark = 1
			@set_background_function: .mark, background_functions$
		endif
	else
		@debug: "formula_background: " + background_functions$
		if background_functions$ <> ""
			background_functions$ =  ""
			.mark = 0
		else
			background_functions$ = "fixed(x)"
			if show_sampling or show_clipping
				background_functions$ = "current(x)"
			endif
			.mark = 1
		endif
		@set_background_function: .mark, background_functions$
	endif
endproc

procedure set_background_function: .mark, .function$
	background_functions$ = .function$
	.fixed_regex$ = "fixed\s*\(\s*x\s*\)"
	.current_regex$ = "current\s*\(\s*x\s*\)"
	if .function$ = ""
		.label$ = "empty(x)"
	elsif index_regex (.function$, "^\s*" +  .fixed_regex$ + "\s*$")
		.label$ = "fixed(x)"
	elsif index_regex (.function$, "^\s*" + .current_regex$ + "\s*$")
		.label$ = "current(x)"
	else
		.label$ = "other(x)"
	endif
	background_functions$ = replace_regex$ (background_functions$, .current_regex$, "(" + function$ + ")", 0)
	@function_rewrite: 1, 0, 0, function$
	.function_fixed$ =  function_rewrite.function_out$
	background_functions$ = replace_regex$ (background_functions$, .fixed_regex$, "(" + .function_fixed$+ ")", 0)
	@debug: "set_background_function: " + background_functions$
	# update table
	@buttons_findFirst: "formula_background"
	.irow = buttons_findFirst.irow
	Set string value: .irow, "label", .label$
	Set numeric value: .irow, "mark", .mark
endproc

procedure fade_change: .irow
	if demoShiftKeyPressed ()
		beginPause ("Change fade times")
		positive ("Fade in time", fade_in_time)
		positive ("Fade out time", fade_out_time)
		endPause ("Cancel", "OK", 2, 1)
	else
		.label$ = object$ [buttons, .irow, "label"]
		if startsWith (.label$, fade_in$)
			fade_in = not fade_in
			@buttons_set_one_mark: "fade", 1, fade_in
		else
			fade_out = not fade_out
			@buttons_set_one_mark: "fade", 2, fade_out
		endif
	endif
endproc

procedure play_as_sound
	selectObject: sound
	Play
	sound_played = 1
	selectObject: buttons
endproc

procedure parameter_change: .irow
	function_query = 0
	.label$ = object$ [buttons, .irow, "label"]
	.ibutton = object [buttons, .irow, "ibutton"]
	.update = 1
	if  startsWith (.label$, upArrow$)
		.formula$ = replace$ (.label$, upArrow$, "+", 1)
	elsif startsWith (.label$, downArrow$)
		.formula$ = replace$ (.label$, downArrow$, "-", 1)
	elsif startsWith (.label$, "*")
		.formula$ = .label$
	else
		.update = 0
	endif
	if demoShiftKeyPressed ()
		@parameter_change_options: .irow
		.update = 0
	endif
	if .update
		@buttons_findFirst: "parameter"
		.irow_par = buttons_findFirst.irow
		.parameter$ = object$ [buttons, .irow_par+.ibutton-1, "label_id"]
		'.parameter$' = '.parameter$''.formula$' ; tric: calculate new value
	endif
	@buttons_set_one_mark_xon: "parameter", .ibutton
	@buttons_set_one_mark_xon: "parameter_value", .ibutton
endproc

procedure parameter_change_options: .irow
	if nparameters > 0
		# find current values: parameter and step_size
		.ibutton = object [buttons, .irow, "ibutton"]

		@buttons_findFirst: "parameter"
		.irow_par = buttons_findFirst.irow
		.label_id$ = object$ [buttons, .irow_par+.ibutton-1, "label_id"]
		.parmi$ = parm_i$ [.ibutton]
		.parmi = evaluate (.parmi$)

		.parmi_upstep$ = .parmi$ + "_upstep"
		.parmi_upstep = evaluate (.parmi_upstep$)
		.parmi_downstep$ = .parmi$ + "_downstep"

		.parmi_multiplier$ = .parmi$ + "_multiplier"
		.parmi_multiplier = evaluate (.parmi_multiplier$)
		@debug: "get_parameter_step_size: " + .label_id$
		beginPause ("Parameter change options")
			comment ("Parameter " + .parmi$)
			real ("Value", string$ (.parmi))
			positive ("Step_size", .parmi_upstep); "'.parmi_upstep'")
			real ("Multiplier", .parmi_multiplier) ;"'.parmi_multiplier'")
		.clicked = endPause ("Cancel", "OK", 2, 1)
		if .clicked = 2
			'.parmi$' = value
			'.parmi_upstep$' = step_size
			'.parmi_downstep$' = step_size
			'.parmi_multiplier$' = multiplier
		endif
	endif
endproc

procedure function_draw_form
	@set_display_ranges
	beginPause ("Function draw options")
		word ("Xmin", xmin$)
		word ("Xmax", xmax$)
		word ("Ymin", ymin$)
		word ("Ymax", ymax$)
		comment ("Grid options")
		integer ("Vertical grid lines", vertical_grid_lines)
		integer ("Horizontal grid lines", horizontal_grid_lines)
		comment ("Function as sound")
		boolean ("Show sampling", show_sampling)
		positive ("Sampling frequency", sampling_frequency)
		natural ("Quantization number of bits", quantization_number_of_bits)
		boolean ("Show reconstructed", show_reconstructed)
		boolean ("Show clipping", show_clipping)
		real ("Sound clip max", sound_clip_max)
		real ("Sound clip min", sound_clip_min)
	.clicked = endPause ("Cancel", "OK", 2, 1)
	if .clicked = 2

		@init
		@get_display_ranges
		function_drawing_method$ = "Curve"
		if show_sampling
			function_drawing_method$ = "Poles"
		endif
		if show_clipping or show_sampling
			@set_background_function: 1, "current(x)"
		endif
	endif
endproc

procedure scale_range: .type$, .label_id$
	.xy$ = left$ (.type$, 1)
	.delta = ('.xy$'max - '.xy$'min) * ('.xy$'range_multiplier - 1)
	if .delta >  2 / sampling_frequency or .label_id$ = yrange_smaller$ or .label_id$ = xrange_wider$
		if .label_id$ = '.xy$'range_smaller$
			.delta = - .delta / '.xy$'range_multiplier
		endif
		if '.xy$'min_c$ = "n" and '.xy$'max_c$ = "n"
			'.xy$'min -= .delta / 2
			'.xy$'max += .delta / 2
		elsif '.xy$'min_c$ = "n" and '.xy$'max_c$ <> "n"
			'.xy$'min += .delta       
		elsif '.xy$'min_c$ <> "n" and '.xy$'max_c$ = "n"
			'.xy$'max += .delta
		endif
	else
		printline ************** action refused: xrange too small (< 2 / sampling_frequency)
	endif
endproc

# The first form to define the function and its parameters

procedure get_function
	beginPause ("Function definition")
		comment ("Define the parameters of the function:")
		text ("Parameters", form_parameters$)
		sentence ("Parameter initial_values", form_parameter_initial_values$)
		sentence ("Parameter limits", form_parameter_limits$)
		comment ("Define the function:")
		text ("Function", form_function$)
		word ("Display variable x as", display_variable_x_as$)
		word ("Xmin", form_xmin$)
		word ("Xmax", form_xmax$)
		word ("Ymin", form_ymin$)
		word ("Ymax", form_ymax$)
	if first_time
		clicked = endPause ("OK", 1)
	else
		clicked = endPause ("Cancel", "OK", 2, 1)
	endif
	if (clicked = 1 and first_time) or clicked = 2
		first_time = 0
		form_parameters$ = parameters$
		form_parameter_initial_values$ = parameter_initial_values$
		form_parameter_limits$ = parameter_limits$
		form_function$ = function$
		form_xmin$ = xmin$
		form_xmax$ = xmax$
		form_ymin$ = ymin$
		form_ymax$ = ymax$
	
		@debug: parameter_limits$
		@get_parameter_names
		@get_parameter_initial_values
		@get_parameter_limits
		@get_display_ranges
	endif
endproc

procedure options
	beginPause ("Options")
		comment ("Do you want the spectrum of the function")
		boolean ("Function and spectrum", function_and_spectrum)
		boolean ("Playable as sound", playable_as_sound)
		real ("Fade_in_time", fade_in_time)
		real ("Fade_out_time", fade_out_time)
	.clicked = endPause ("Cancel", "OK", 2, 1)
	if .clicked = 2
		# first initialize and then set new background ...
		@init
	endif
endproc

procedure spectrum_options
	@debug: "spectrum_options"
	if demoShiftKeyPressed ()
		beginPause ("Spectrum display options")
			real ("Minimum_frequency", minimum_frequency)
			real ("Maximum_frequency", maximum_frequency)
			boolean ("Maximum frequency is Nyquist", maximum_frequency_is_Nyquist)
			real ("Minimum_power", minimum_power)
			real ("Maximum_power", maximum_power)
			boolean ("Trace frequency", trace_frequency)
			real ("Frequency traced", frequency_traced)
			optionMenu ("Spectrum_calculation", spectrum_calculation)
				option ("DFT")
				option ("FFT")
		.clicked = endPause ("Cancel", "OK", 2, 1)
		if .clicked = 2
			if minimum_frequency >= maximum_frequency
				minimum_frequency = 0
				maximum_frequency = 2000
			endif
			if minimum_power >= maximum_power
				minimum_power = 0
				maximum_power = 100
			endif
			if maximum_frequency_is_Nyquist
				maximum_frequency = sampling_frequency / 2
			endif
		endif
		@debug: "spectrum_options" + string$ (.clicked) + " " + string$ (minimum_frequency)
		... + " " + string$ (maximum_frequency) + " " + string$ (minimum_power)
		... + " " + string$ (maximum_power)
	else
		demo Font size: number (size_spectrum$)
		demo Select outer viewport: vp_spectrum#[1], vp_spectrum#[2], vp_spectrum#[3], vp_spectrum#[4]
		if maximum_frequency_is_Nyquist
			maximum_frequency = sampling_frequency / 2
		endif
		demo Axes: minimum_frequency, maximum_frequency, minimum_power, maximum_power 
		f_query = demoX ()
		.y = demoY ()
		if f_query > minimum_frequency and f_query < maximum_frequency and .y <= minimum_power
			@spectrum_query: f_query
			p_query = spectrum_query.p_query
			spectrum_query = 1
		endif 
	endif
endproc

procedure error .message$
	beginPause ("Error")
	comment("Error: " + .message$)
	endPause ("Continue", 1)
endproc

# The first thing to call

procedure init
	function_query = 0
	function_buttons_initialised = 0
	if buttons <> 0
		removeObject: buttons
	endif
	buttons = Create Table with column names: "buttons", 0, 
	... "type vpx1 vpx2 vpy1 vpy2 x1 x2 y1 y2 nbuttons ibutton label_id label size mark xon clicked"
	if new_function
		@get_function
		new_function = 0
	endif
	fade_in = 0
	fade_out = 0
	@interface_definitions
endproc

procedure get_parameter_initial_values
	delim$ = "\s+"
	@get_items: parameter_initial_values$ + space$
	.nitems = get_items.nitems
	if .nitems < nparameters
		exitScript: "set_initial_values: not enough initial values"
	endif
	for .i to nparameters
		.pt$ = get_items.item$ [.i]
		@parse_two: .pt$  
		.val$ = parse_two.p1$
		.parmi$ = parm_i$ [.i]
		'.parmi$' = '.val$'
		.step$ = parse_two.p2$
		.step = '.step$'
		if parse_two.not_present = 2
			.step /= 10
			if .step = 0
				.step = 0.1
			endif
		endif
		.upstep$ = parm_i$ [.i] + "_upstep"
		'.upstep$' = .step
		.downstep$ = parm_i$ [.i] + "_downstep"
		'.downstep$' = .step
		.multiplier$ = parm_i$ [.i] + "_multiplier"
		'.multiplier$' = -1
		@debug: "get_parameter_initial_values: " + string$ (.i) + " " + .upstep$ + " " + string$ (.step)
	endfor
	delim$ = ";"
endproc

# parameters can be given as p1:p2 or as p1
# p1 is used in the formula function and p2 is used to display the formula in a nice way
# e.g. phase:\fi
# Treat the variable as an extra parameter. This comes in handy when we evaluate a formula.

procedure get_parameter_names
	delim$ = "\s+"
	@get_items: parameters$ + space$
	nparameters = get_items.nitems
	if nparameters = 0
		exitScript: "get_parameter_names: No parameters"
	endif
	labels_parameter$ = ""
	for .i to nparameters
		.p2$ = get_items.item$ [.i]
		@debug: "get_parameter_names: " + string$ (.i) + " " + .p2$
		@parse_two: .p2$
		parm_i$ [.i] = parse_two.p1$
		parm_f$ [.i] = parse_two.p2$
		labels_parameter$ = labels_parameter$ + parm_i$ [.i] + ";"
	endfor
	.nparp1 = nparameters + 1
	parm_i$ [.nparp1] = "x"
	parm_f$ [.nparp1] = "x"
	delim$ = ";"
endproc

# parse a:b -> a b; a: -> a a; a -> a a; :a -> a a

procedure parse_two .s$
	.length = length (.s$)
	.colon = index (.s$, ":")
	if .colon = 0
		.not_present = 2
		.p1$ = .s$
		.p2$ = .s$
	elsif .colon = 1
		.not_present = 1
		.p2$ = right$ (.s$, .length - .colon)
		.p1$ = .p2$
	else
		.not_present = 0
		.p1$ = left$ (.s$, .colon - 1)
		.p2$ = right$ (.s$, .length - .colon)
	endif 
endproc

# check if given xmin xmax and ymin ymax are fixed or variable

procedure get_display_ranges
	@check_num_constant: xmax$
	xmax = check_num_constant.num
	xmax_c$ = check_num_constant.c$
	@check_num_constant: xmin$
	xmin = check_num_constant.num
	xmin_c$ = check_num_constant.c$
	@check_num_constant: ymax$
	ymax = check_num_constant.num
	ymax_c$ = check_num_constant.c$
	@check_num_constant: ymin$
	ymin = check_num_constant.num
	ymin_c$ = check_num_constant.c$
	@debug: xmax_c$ + " " + xmin_c$ + " " + ymax_c$ + " " + ymin_c$
	if xmax <= xmin
		exitScript: "xmax must be greater than xmin"
	endif
	if ymax <= ymin
		@get_yrange
	endif
endproc

procedure set_display_ranges
	xmax$ = string$ (xmax)
	if xmax_c$ = "y"
		xmax$ = xmax$ + "c"
	endif
	xmin$ = string$ (xmin)
	if xmin_c$ = "y"
		xmin$ = xmin$ + "c"
	endif
	ymax$ =  string$ (ymax)
	if ymax_c$ = "y"
		ymax$ = ymax$ + "c"
	endif
	ymin$ =  string$ (ymin)
	if ymin_c$ = "y"
		ymin$ = ymin$ + "c"
	endif
endproc

procedure check_num_constant: .num$
	.i = index (.num$, "c")
	.c$ = "n"
	if .i > 0
		.num$ = left$ (.num$, .i - 1)
		.c$ = "y"
	endif
	.num = number (.num$)
endproc

# If user did not specify range, calculate it

procedure get_yrange
	.f = Create Sound from formula: "function", 1, xmin, xmax, function_draw_npoints/(xmax-xmin), function$
	ymin = Get minimum: 0, 0, "Sinc70"
	ymax = Get maximum: 0, 0, "Sinc70"
	.yrange = ymax - ymin
	ymin = floor((ymin - 0.1 * .yrange) * 100) / 100
	ymax =  ceiling ((ymax + 0.1 * .yrange) * 100) / 100
	Remove
endproc

procedure get_parameter_limits
	delim$ = "\s+"
	@get_items: parameter_limits$
	.nitems = get_items.nitems
	
	for .i to nparameters
		.ip = 2 * .i - 1
		parm_l$  [.i]= "n"
		if .ip <= .nitems
			parm_l$ [.i]= get_items.item$ [.ip]
		endif
		.ip += 1
		parm_u$ [.i] = "n"
		if .ip <= .nitems
			parm_u$ [.i] = get_items.item$ [.ip]
		endif
	endfor
	delim$ = ";"
endproc

# get items form a list where elements are separated with delim$
# Sets up local variables .nitems, .item$[1], .item$[2], ... .item$[.nitems] etc 
# not re-entrant. Always get items immediately after call

procedure get_items: .s$
	.nitems = 0
	repeat
		.dpos = index_regex (.s$, delim$)
		@debug: "get_items: " + string$ (.dpos) + " " + .s$
		if .dpos > 0
			.nitems += 1
			.item$ = left$ (.s$, .dpos - 1)
			.item$ [.nitems] = .item$
			.s$ = replace$ (.s$,  .item$, "", 1)
			# strings may have \f \t etc. but no ;
			.s$ = replace_regex$ (.s$, delim$, "", 1)
		endif
	until .dpos = 0
endproc

procedure sound_create
	.fs = min (44100, floor (44100 / (xmax - xmin)))
	if show_sampling
		if (xmax - xmin) > 1 and sampling_frequency > .fs
			beginPause ("Sampling frequency")
				comment ("Your segment is too long to show with this sampling frequency")
				comment ("We have reduced the sampling frequency to" + string$(.fs))
			endPause ("Continue", 1, 1)
			sampling_frequency = .fs
		else
			.fs = sampling_frequency
		endif
	endif
	if sound
		select sound
		Remove
	endif
	sound = Create Sound from formula: "f", 1, xmin, xmax, .fs, function$
	if show_sampling
		if 1
			Formula: "if self <-1 then -1 else if self > 1 then 1 else self fi fi"
			.ddy = 2/(2^quantization_number_of_bits - 1)
			# +0.5 mid-riser
			.scale = 2^(quantization_number_of_bits-1)-0.5
			Formula: "((round ((self+1) / .ddy)) - .scale) / .scale"
		endif
		if sound_reconstructed
			selectObject:  sound_reconstructed
			Remove
		endif
		select sound
		.rc = Copy: "rc"
		if show_clipping
			Formula: "if self < sound_clip_min then sound_clip_min else if self > sound_clip_max then sound_clip_max else self fi fi"
		endif
		sound_reconstructed = Resample: 44100, 10
#		sound_reconstructed = Copy: "rc"
		removeObject: .rc
	endif
	selectObject: sound
	if fade_in
		.f = 1 /( 2 * fade_in_time)
		Formula:  "if (x - 'xmin') < fade_in_time then self*(0.5*(1+cos(2*pi*'.f'*(x-'xmin'+fade_in_time)))) else self fi"
	endif
	if fade_out
		.f = 1 /( 2 * fade_out_time)
		Formula: "if ('xmax'-x) < fade_out_time then self*(0.5*(1+cos(2*pi*'.f'*(x-'xmax'+fade_in_time)))) else self fi"
	endif
	if show_clipping
		Formula: "if self < sound_clip_min then sound_clip_min else if self > sound_clip_max then sound_clip_max else self fi fi"
	endif
endproc

procedure function_draw: .irow, .vpx1, .vpx2, .vpy1, .vpy2
	demo Font size: number (size_function$)
	demo Select outer viewport: .vpx1, .vpx2, .vpy1, .vpy2
	demo Axes: xmin, xmax, ymin, ymax
	@debug: string$ (.vpx1) + " " + string$ (.vpx2) + " " + string$ (.vpy1) + " " + string$ (.vpy2)
	.ymax = ymax
	.ymin = ymin
	demo Colour: color_parameter$
	demo Line width: 2
	@sound_create
	sound_function$ = function$
	# fade_in and fade_out first;
	# clipping has priority over all other things
	.xfrom = xmin
	demo Colour: color_fade$
	if fade_in
		.xfrom = xmin + fade_in_time
		demo Draw where: xmin, xmax, ymin, ymax, "no", function_drawing_method$, "x<= .xfrom"
	endif
	.xto = xmax
	if fade_out and praatversion
		.xto = xmax - fade_out_time
		demo Draw where: xmin, xmax, ymin, ymax, "no", function_drawing_method$, "x> .xto"
	endif
	is_clipped$ = "(self <= sound_clip_min or self >= sound_clip_max)"
	if show_clipping
		demo Colour: color_clip$
		demo Draw where: xmin, xmax, ymin, ymax, "no", function_drawing_method$, is_clipped$
		demo Colour: color_parameter$
		# is there something normal to draw
		if .xfrom < .xto
			demo Draw where: xmin, xmax, ymin, ymax, "no", function_drawing_method$, "(not " + is_clipped$ + ") and (x>.xfrom and x<.xto)"
		endif
	else
		demo Colour: color_parameter$
		if function_drawing_method$ = "Curve"
			.where$ = "(self>=" + string$ (ymin) + " and self<=" + string$ (ymax) + ") and (x>.xfrom and x<.xto)"
			demo Draw where: xmin, xmax, ymin, ymax, "no", function_drawing_method$, .where$
		else
			demo Draw where: xmin, xmax, ymin, ymax, "no", function_drawing_method$, "(x>.xfrom and x<.xto)"
		endif
	endif
	demo Line width: 1
	if background_functions$ <> ""
		demo Grey
		demo Draw function: xmin, xmax, function_draw_npoints, background_functions$
	endif
	if show_reconstructed and sound_reconstructed <> 0
		selectObject: sound_reconstructed
		demo Blue
		demo Draw: xmin, xmax, ymin, ymax, "no", "Curve"
		demo Colour: color_normal$
	endif
	
	if show_clipping
		demo Colour: color_clip$
		if sound_clip_min >= .ymin and sound_clip_min <= .ymax
			demo One mark left: sound_clip_min, "no", "yes", "yes", " "
		endif
		if sound_clip_max >= .ymin and sound_clip_max <= .ymax
			demo One mark left: sound_clip_max, "no", "yes", "yes", " "
		endif
	endif
	demo Colour: color_normal$
	demo Dotted line
	demo Draw rectangle: xmin, xmax, .ymin, .ymax
	if ymin*ymax < 0
		demo One mark left: 0, "yes", "yes", "yes", ""
		demo One mark right: 0, "yes", "yes", "no", ""
	endif
	demo One mark left: ymax, "yes", "yes", "no", ""
	demo One mark left: ymin, "yes", "yes", "no", ""
	demo One mark right: ymax, "yes", "yes", "no", ""
	demo One mark right: ymin, "yes", "yes", "no", ""
	demo One mark bottom: xmin, "yes", "yes", "no", ""
	demo One mark bottom: xmax, "yes", "yes", "no", ""
	demo Marks bottom every: 1, 20, "no", "yes", "no"
	demo Marks top every: 1, 10, "no", "yes", "no"
	if xmin*xmax < 1
		demo One mark bottom: 0, "yes", "yes", "yes", ""
	endif
	demo Text bottom: "no", display_variable_x_as$ + " \->"
	demo Text left: "yes", "y(" + display_variable_x_as$ + ") \->"
	demo Solid line
	if function_query
		@function_query_draw
	endif
	@function_grid
	# we now know the dimension of the drawing and can add additional buttons
	@function_buttons: .vpx1, .vpx2, .vpy1, .vpy2, number (size_function$)
endproc

procedure draw_background_functions 
# given an x value, query for the y
endproc

procedure function_options
	demo Font size: number (size_function$)
	demo Select outer viewport: vp_function#[1], vp_function#[2], vp_function#[3], vp_function#[4]
	demo Axes: xmin, xmax, ymin, ymax
	x_query = demoX ()
	.y = demoY ()
	if x_query > xmin and x_query < xmax and .y <= ymin
		@function_query
	else
		if demoShiftKeyPressed ()
			@function_draw_form
		endif
	endif  
endproc

procedure function_query
	demo Font size: number (size_function$)
	demo Select outer viewport: vp_function#[1], vp_function#[2], vp_function#[3], vp_function#[4]
	demo Axes: xmin, xmax, ymin, ymax
	function_query = 1
	function_r$ = replace_regex$ (function$, "(?<=^|\W)x(?=\W|$)", "x_query", 0)
	y_query = 'function_r$'
	if show_clipping
		y_query = max (y_query, sound_clip_min)
		y_query = min (y_query, sound_clip_max)
	endif
endproc

procedure spectrum_query: .frequency
	demo Font size: number (size_spectrum$)
	demo Select outer viewport: vp_spectrum#[1], vp_spectrum#[2], vp_spectrum#[3], vp_spectrum#[4]
	demo Axes: minimum_frequency, maximum_frequency, minimum_power, maximum_power
	selectObject: spectrum
	.bin = Get bin number from frequency: .frequency
	.real = Get real value in bin: .bin
	.imag = Get imaginary value in bin: .bin
	.binw = Get bin width
	.pd = 2 * (.real^2 + .imag^2)
	.p_query = 10*log10 (.pd * .binw / 4e-10)
endproc


procedure spectrum_query_draw: .f_query, .p_query
	if .f_query <> undefined and .f_query >= minimum_frequency and .f_query <= maximum_frequency
		if abs(.f_query) < precision
			.f_query = 0
		endif
		if abs(.p_query) < precision
			.p_query = 0
		endif
		.f_query$ = fixed$ (.f_query, 2)
		.p_query$ = fixed$ (.p_query, 2)
		.sub_bottom = 0.06 * (maximum_power - minimum_power)
		@debug: "spectrum_query_draw: " + .f_query$ + " " + .p_query$
		demo Colour: color_query_link$
		.p_query = if .p_query < minimum_power then minimum_power else .p_query endif
		.p_query = min (.p_query, maximum_power)
		demo Dotted line
		demo Draw line: .f_query, minimum_power - .sub_bottom, .f_query, .p_query
		if .p_query > minimum_power
			demo Draw line: .f_query, .p_query, maximum_frequency, .p_query
		endif
		demo Text: maximum_frequency+0.04*(maximum_frequency-minimum_frequency), "Left", .p_query, "Half", .p_query$
		demo Solid line
		demo Text: .f_query, "Centre", minimum_power - .sub_bottom, "Top", .f_query$
		demo Colour: color_normal$
	else
		spectrum_query = 0
	endif
endproc

procedure function_query_draw
	if x_query <> undefined and x_query >= xmin and x_query <= xmax
		if abs(x_query) < precision
			x_query = 0
		endif
		if abs(y_query) < precision
			y_query = 0
		endif
		x_query$ = fixed$ (x_query, 2)
		y_query$ = fixed$ (y_query, 2)
		.sub_bottom = 0.06*(ymax-ymin)
		demo Colour: color_query_link$
		if y_query > ymin
			.y_query = min (y_query, ymax)
			demo Dotted line
			demo Draw line: x_query, ymin - .sub_bottom, x_query, .y_query
			if y_query <= ymax
				demo Draw line: x_query, .y_query, xmax, .y_query
				demo Text: xmax+0.03*(xmax-xmin), "Left", y_query, "Half", y_query$
			endif
			demo Solid line
		endif
		demo Text: x_query, "Centre", ymin - .sub_bottom, "Top", x_query$
		demo Colour: color_normal$
	else
		function_query = 0
	endif
endproc

procedure function_grid
	if horizontal_grid_lines > 0
		demo Marks left: horizontal_grid_lines, "no", "no", "yes"
	endif
	if vertical_grid_lines > 0
		demo Marks bottom: vertical_grid_lines, "no", "no", "yes"
	endif
endproc

procedure function_buttons .vpx1 .vpx2 .vpy1 .vpy2 .fontsize
	if not function_buttons_initialised
		@function_buttons_initialize: .vpx1, .vpx2, .vpy1, .vpy2, .fontsize
	endif
	function_buttons_initialised = 1
	# drawing will be taken care of; we're in the table now after the function draw
endproc

procedure spectrum_draw .irow .vpx1 .vpx2 .vpy1 .vpy2
	demo Font size: number (size_spectrum$)
	demo Select outer viewport: .vpx1, .vpx2, .vpy1, .vpy2
	if maximum_frequency_is_Nyquist
		maximum_frequency = sampling_frequency / 2
	endif
	demo Axes: minimum_frequency, maximum_frequency, minimum_power, maximum_power

	.dft_or_fft$ = "no"
	if spectrum_calculation = 2
		.dft_or_fft$ = "yes"
	endif
	if not spectrum_query
		if spectrum <> 0
			removeObject: spectrum
		endif
		selectObject: sound
		if show_reconstructed and sound_reconstructed <> 0
			selectObject: sound_reconstructed
		endif
		spectrum = To Spectrum: .dft_or_fft$
	endif
	if background_functions$ <> ""
		if spectrum_background > 0
			removeObject: spectrum_background
		endif
		.sb = Create Sound from formula: "sb", 1, xmin, xmax, 44100, background_functions$
		spectrum_background = To Spectrum: spectrum_calculation
		demo Colour: "Grey"
		demo Draw: minimum_frequency, maximum_frequency, minimum_power, maximum_power, "no"
		removeObject: .sb
	endif
	selectObject: spectrum
	demo Colour: color_parameter$
	demo Line width: 2
	demo Draw: minimum_frequency, maximum_frequency, minimum_power, maximum_power, "no"
	demo Line width: 1
	demo Draw inner box
	demo Colour: color_normal$
	demo Marks left: 6, "yes", "yes", "yes"
	demo Marks bottom: 6, "yes", "yes", "yes"
	demo Text top: "no", "Frequency (Hz) \->"
	if spectrum_query
		@spectrum_query_draw: f_query, p_query
		spectrum_query = 0
	endif
	if trace_frequency and frequency_traced < maximum_frequency
		@spectrum_query: frequency_traced
		.p_query = spectrum_query.p_query
		@spectrum_query_draw: frequency_traced, .p_query
		spectrum_query = 0
	endif
	selectObject: buttons
endproc

# definition of the interface components

procedure interface_data
	# function must be last because xrange vp is within function vp!

	button_types$ = "parameter;parameter_multiplier;parameter_upstep;parameter_downstep;parameter_value;xrange;yrange;function;formula;formula_background;options;"

	.vpx1p = 7.5
	.vpx2p = .vpx1p + 15
	.vpy1p = 1
	.vpy2p = .vpy1p + 19
	if show_sampling
		.dy = 4
		.vpy2p = .vpy1p + 19 - .dy

		button_types$ = "sampling;" +  button_types$
		vp_parameter_sampling# = { .vpx1p, .vpx2p, .vpy1p, .vpy2p }

		.vpy1_sampling = .vpy2p + 0.5
		.vpy2_sampling = .vpy1_sampling + .dy - 0.5
		.vpx1_sampling = .vpx1p + 2
		# .vpx2 is known after value!
		size_sampling$ = "16"
		labels_sampling$ = "T;*2;/2;^^draw_sampling_time_label;^^draw_sampling_frequency_label;"
		layout_sampling# = { 5, 1, 100, 1, 0 }
		one_mark_sampling# = { 0, 0 }
		marks_sampling$ = ""
	else
		.vpy2p = .vpy1p + 19
	endif

	#labels_parameter$ defined in get_parameter_names
	size_parameter$ = "16"
	vp_parameter# = { .vpx1p, .vpx2p, .vpy1p, .vpy2p }
	layout_parameter# = {1, nparameters, 3, 100, 1 }
	one_mark_parameter# = { 1, 1 }
	marks_parameter$ = ""

	labels_parameter_multiplier$ = ""
	for .i to nparameters
		labels_parameter_multiplier$ = labels_parameter_multiplier$ + "^^draw_parameter_multiplier_label;"
	endfor
	size_parameter_multiplier$ = "16"
	.vpx1pm = .vpx2p + 2
	.vpx2pm = .vpx1pm + 5
	vp_parameter_multiplier# = { .vpx1pm, .vpx2pm, .vpy1p, .vpy2p }
	layout_parameter_multiplier# = { 1, nparameters, 3, 100, 0 }
	one_mark_parameter_multiplier# = { 0, 0 }
	marks_parameter_multiplier$ = ""

	labels_parameter_upstep$ = ""
	for .i to nparameters
		labels_parameter_upstep$ = labels_parameter_upstep$ + "^^draw_parameter_upstep_label;"
	endfor
	size_parameter_upstep$ = "16"
	.vpx1pu = .vpx2pm + 2
	.vpx2pu = .vpx1pu + 10
	vp_parameter_upstep# = { .vpx1pu, .vpx2pu, .vpy1p, .vpy2p }
	layout_parameter_upstep# = {1, nparameters, 3, 100, 0 }
	one_mark_parameter_upstep# = { 0, 0 }
	marks_parameter_upstep$ = ""

	labels_parameter_downstep$ = ""
	for .i to nparameters
		labels_parameter_downstep$ = labels_parameter_downstep$ + "^^draw_parameter_downstep_label;"
	endfor
	size_parameter_downstep$ = "16"
	.vpx1pd = .vpx2pu + 2
	.vpx2pd = .vpx1pd + 10
	vp_parameter_downstep# = { .vpx1pd, .vpx2pd, .vpy1p, .vpy2p }
	layout_parameter_downstep# = {1, nparameters, 3, 100, 0 }
	one_mark_parameter_downstep# = { 0, 0 }
	marks_parameter_downstep$ = ""

	labels_parameter_value$ = ""
	for .i to nparameters
		labels_parameter_value$ = labels_parameter_value$ + "^^draw_parameter_value_label;"
	endfor
	size_parameter_value$ = "16"
	.vpx1pv = .vpx2pd + 2
	.vpx2pv = .vpx1pv + 16
	vp_parameter_value# = { .vpx1pv, .vpx2pv, .vpy1p, .vpy2p }
	layout_parameter_value# = { 1, nparameters, 3, 100, 1 }
	one_mark_parameter_value# = { 1, 1 }
	marks_parameter_value$ = ""

	if show_sampling
		.vpx2_sampling = .vpx2pv - 2
		vp_sampling# = { .vpx1_sampling, .vpx2_sampling, .vpy1_sampling, .vpy2_sampling }
		.vpx2_quantization = .vpx2_sampling
		vp_quantization# = vp_sampling#
	endif

	labels_function$ = "^^function_draw;"
	size_function$  = "16"
	.vpx1f = 0
	.vpx2f = .vpx1f + 100
	.vpy1f = 30
	.vpy2f = .vpy1f + 60
	vp_function# = { .vpx1f, .vpx2f, .vpy1f, .vpy2f }
	layout_function# = { 1, 1, 100, 100, 0 }
	one_mark_function# = { 0, 0 }
	marks_function$ = ""
	
	labels_formula$ = "^^formula_draw;^^formula_draw_numeric;"
	size_formula$  = "16"
	.vpx1_formula = 10
	.vpx2_formula = 100
	.vpy1_formula = 90
	.vpy2_formula = 100
	vp_formula# =  { .vpx1_formula, .vpx2_formula, .vpy1_formula, .vpy2_formula }
	layout_formula# = { 1, 2, 10, 100, 0 }
	one_mark_formula# = { 0, 0 }
	marks_formula$ = ""
	
	labels_formula_background$ = "empty(x);"
	size_formula_background$  = "14"
	.vpy1_background = .vpy1_formula + (.vpy2_formula - .vpy1_formula) / 4
	.vpy2_background = .vpy1_background + (.vpy2_formula - .vpy1_formula) / 2
	vp_formula_background# = { 1, .vpx1_formula - 1, .vpy1_background, .vpy2_background }
	layout_formula_background# = { 1, 1, 100, 100, 0 }
	one_mark_formula_background# = { 0, 0 }
	marks_formula_background$ = ""

	labels_xrange$ = xrange_wider$ + ";" + xrange_smaller$ + ";"
	size_xrange$  = "14"
	.vpx1_xrange = 36
	.vpx2_xrange = .vpx1_xrange + 28
	.vpy2_xrange = .vpy1f + 1
	.vpy1_xrange = .vpy2_xrange - 5
	vp_xrange# = { .vpx1_xrange, .vpx2_xrange, .vpy1_xrange, .vpy2_xrange }
	layout_xrange# = { 2, 1, 4, 100, 0 }
	one_mark_xrange# = { 0, 0 }
	marks_xrange$ = ""

	labels_yrange$ = yrange_wider$+ ";" + yrange_smaller$ + ";"
	size_yrange$  = "12"
	vp_yrange# =  { 1, 4, 70, 85 }
	layout_yrange# = { 1, 2, 100, 100, 0 }
	one_mark_yrange# = { 0, 0 }
	marks_yrange$ = ""
	
	;labels_control$ = "New function;"
	;size_control$  = "16"
	;vp_control# = { 85, 99, 1, 5 }
	;layout_control# = { 1, 1, 100, 100, 0 }
	;one_mark_control# = { 0, 0 }
	;marks_control$ = ""
	
	labels_options$ = "Options;"
	size_options$  = "16"
	vp_options# = { 85, 99, 1, 5 }
	layout_options# =  { 1, 1, 100, 100, 0 }
	one_mark_options# = { 0, 0 }
	marks_options$ = ""

	if function_and_spectrum
		button_types$ = button_types$ + "spectrum;"
		.vpx2f = .vpx1f + 60
		vp_function# = { .vpx1f, .vpx2f, .vpy1f, .vpy2f }
		vp_xrange# = { 18, 42, .vpy1_xrange, .vpy2_xrange }
		labels_spectrum$ = "^^spectrum_draw;"
		vp_spectrum# = { .vpx2f, 100, .vpy1f, .vpy2f }
		size_spectrum$  = "16"
		layout_spectrum# = { 1, 1, 100, 100, 0 }
		one_mark_spectrum# = { 0, 0 }
		marks_spectrum$ = ""
	endif

	if playable_as_sound
		button_types$ = button_types$ + "play;fade;"
		labels_play$ = "Play;"
		.vpx1_play = .vpx2pv + 5
		.vpx2_play = .vpx1_play + 10
		.vpy1_play = .vpy1p + (.vpy2p - .vpy1p)/4*(4-1)/2
		.vpy2_play = .vpy1_play + (.vpy2p - .vpy1p)/4
		vp_play# = { .vpx1_play, .vpx2_play, .vpy1_play, .vpy2_play }
		size_play$ = "16"
		layout_play# = { 1, 1, 5, 1, 0 }
		one_mark_play# = { 0, 0 }
		marks_play$ = ""
		labels_fade$ = "^^draw_fade_in_label;^^draw_fade_out_label;"
		.vpx1_fade = .vpx1f + 5
		.vpx2_fade = .vpx2f - 5
		vp_fade# = { .vpx1_fade, .vpx2_fade, .vpy1_xrange, .vpy2_xrange }
		size_fade$ = "16"
		layout_fade# = { 2, 1, 0.15, 1, 0 }
		one_mark_fade# = { 0, 0 }
		marks_fade$ = ""
	endif
endproc

procedure draw_fade_in_label: .irow, .vpx1, .vpx2, .vpy1, .vpy2
	demo Select inner viewport: .vpx1, .vpx2, .vpy1, .vpy2
	demo Axes: .vpx1, .vpx2, .vpy1, .vpy2
	demo Colour: color_parameter$
	demo Draw rounded rectangle: .vpx1, .vpx2, .vpy1, .vpy2, 3
	.label$ = fade_in$ + " " + string$ (fade_in_time)
	Set string value: .irow, "label", .label$
	.color$ = color_normal$
	if object [buttons, .irow, "mark"]
		.color$ = color_fade$
	endif
	demo Colour: .color$
	demo Text: (.vpx1+.vpx2)/2, "Centre", (.vpy1+.vpy2)/2, "Half",  .label$
	demo Colour: color_normal$
endproc

procedure draw_fade_out_label .irow .vpx1 .vpx2 .vpy1 .vpy2
	demo Select inner viewport: .vpx1, .vpx2, .vpy1, .vpy2
	demo Axes: .vpx1, .vpx2, .vpy1, .vpy2
	demo Colour: color_parameter$
	demo Draw rounded rectangle: .vpx1, .vpx2, .vpy1, .vpy2, 3
	.label$ = string$ (fade_out_time) + " " + fade_out$
	Set string value: .irow, "label", .label$
	.color$ = color_normal$
	if object [buttons, .irow, "mark"]
		.color$ = color_fade$
	endif
	demo Colour: .color$
	demo Text: (.vpx1+.vpx2)/2, "Centre", (.vpy1+.vpy2)/2, "Half",  .label$
	demo Colour: color_normal$
endproc

procedure draw_parameter_value_label: .irow, .vpx1, .vpx2, .vpy1, .vpy2
	demo Select inner viewport: .vpx1, .vpx2, .vpy1, .vpy2
	demo Axes: .vpx1, .vpx2, .vpy1, .vpy2
	.ibutton = object [buttons, .irow, "ibutton"]
	.parmi$ = parm_i$ [.ibutton]
	.parmi = evaluate (.parmi$)
	if abs(.parmi) < precision
		.parmi = 0
	endif
	.parmif$ = fixed$ (.parmi, 2)
	demo Colour: color_parameter$
	demo Draw rounded rectangle: .vpx1, .vpx2, .vpy1, .vpy2, 3
	.label$ = "= " + .parmif$
	Set string value: .irow, "label", .label$
	.color$ = color_normal$
	if object [buttons, .irow, "mark"]
		.color$ = color_parameter$
	endif
	demo Colour: .color$
	demo Text: .vpx1, "Left", (.vpy1+.vpy2)/2, "Half",  .label$
	demo Colour: color_normal$
endproc

procedure draw_parameter_multiplier_label: .irow, .vpx1, .vpx2, .vpy1, .vpy2
	demo Select inner viewport: .vpx1, .vpx2, .vpy1, .vpy2
	demo Axes: .vpx1, .vpx2, .vpy1, .vpy2
	demo Colour: color_parameter$
	demo Draw rounded rectangle: .vpx1, .vpx2, .vpy1, .vpy2, 3
	.label$ = "*-1"
	.ibutton = object [buttons, .irow, "ibutton"]
	@buttons_findFirst: "parameter"
	.irow_par = buttons_findFirst.irow
	.parm$ = object$ [buttons, .irow_par+.ibutton-1, "label_id"]
	.parm$ = .parm$ + "_multiplier"
	.val = evaluate (.parm$)
	.label$ = "*" + string$ (.val)
	Set string value: .irow, "label", .label$
	demo Colour: color_normal$
	demo Text: (.vpx1+.vpx2)/2, "Centre", (.vpy1+.vpy2)/2, "Half",  .label$
endproc

procedure draw_parameter_upstep_label: .irow, .vpx1, .vpx2, .vpy1, .vpy2
	demo Select inner viewport: .vpx1, .vpx2, .vpy1, .vpy2
	demo Axes: .vpx1, .vpx2, .vpy1, .vpy2
	demo Colour: color_parameter$
	demo Draw rounded rectangle: .vpx1, .vpx2, .vpy1, .vpy2, 3
	.ibutton = object [buttons, .irow, "ibutton"]
	@buttons_findFirst: "parameter"
	.irow_par = buttons_findFirst.irow
	.parm$ = object$ [buttons, .irow_par+.ibutton - 1, "label_id"]
	.parm$ = .parm$ + "_upstep"
	.val = evaluate (.parm$)
	.label$ = upArrow$ + " " + string$ (.val)
	Set string value: .irow, "label", .label$
	demo Colour: color_normal$
	demo Text: (.vpx1+.vpx2)/2, "Centre", (.vpy1+.vpy2)/2, "Half", .label$
endproc

procedure draw_parameter_downstep_label: .irow, .vpx1, .vpx2, .vpy1, .vpy2
	demo Select inner viewport: .vpx1, .vpx2, .vpy1, .vpy2
	demo Axes: .vpx1, .vpx2, .vpy1, .vpy2
	demo Colour: color_parameter$
	demo Draw rounded rectangle: .vpx1, .vpx2, .vpy1, .vpy2, 3
	.ibutton = object [buttons, .irow, "ibutton"]
	@buttons_findFirst: "parameter"
	.irow_par = buttons_findFirst.irow
	.parm$ = object$ [buttons, .irow_par+.ibutton-1, "label_id"]
	.parm$ = .parm$ + "_downstep"
	.val = evaluate (.parm$)
	.label$ = downArrow$ + " " + string$ (.val)
	Set string value: .irow, "label", .label$
	# find parameter[.ibutton]
	demo Colour: color_normal$
	demo Text: (.vpx1+.vpx2)/2, "Centre", (.vpy1+.vpy2)/2, "Half", .label$
endproc

# Put all the interface info into a table

procedure interface_definitions
	@interface_data
	@get_items: button_types$
	.ntypes = get_items.nitems
	for .i to .ntypes
		.type$ [.i] = get_items.item$ [.i]
	endfor
	for .i to .ntypes
		.type$ = .type$ [.i]
		.vp# = vp_'.type$'#
		.labels$ = labels_'.type$'$
		.size$ = size_'.type$'$
		.layout# = layout_'.type$'#
		if debug
			appendInfoLine: .type$, " {", .vp#, "} {", .layout#, "} ", .size$, " ", .labels$
		endif
		@buttons_init_positions: .type$, .vp#[1], .vp#[2], .vp#[3], .vp#[4],  .layout#[1], .layout#[2], .layout#[3], .layout#[4], .layout#[5]
		@buttons_init_labels: .type$, number (.size$), .labels$
		.one_mark# = one_mark_'.type$'#
		@buttons_set_one_mark: .type$, .one_mark#[1], .one_mark#[2]

		if marks_'.type$'$ <> ""
			.marks$ = marks_'.type$'$
			@buttons_set_marks: .type$, .marks$
		endif
	endfor
endproc

procedure function_buttons_initialize: .vpx1, .vpx2, .vpy1, .vpy2, .font_size
  .types$ = "function_buttons;"
endproc

# calculate the orientation of a series of buttons layed out in an array of nx x ny

procedure buttons_init_positions: .type$, .vpx1, .vpx2, .vpy1, .vpy2, .nx, .ny, .sx, .sy, .xon
	selectObject: buttons

	.nbuttons = .nx * .ny
	.dx = (.vpx2 - .vpx1) / ((1 + .sx) * .nx - 1)
	.dy = (.vpy2 - .vpy1) / ((1 + .sy) * .ny - 1)
	.bw = .sx * .dx
	.bh = .sy * .dy
	@debug: .type$ + " nx=" + string$ (.nx) + " ny=" + string$ (.ny) + " sx=" + string$ (.sx) 
	... + " sy=" + string$ (.sy) + " dx=" + string$ (.dx) + " dy=" + string$ (.dy)
	... + " bw=" + string$ (.bw) + " bh=" + string$ (.bh)
	.ibutton = 1
	for .i to .ny
		for .j to .nx
			.x1 = .vpx1 + (.j - 1) * (1 + .sx) * .dx
			.x2 = .x1 + .bw
			.y2 = .vpy2 - (.i - 1) * (1 + .sy) * .dy
			.y1 = .y2 - .bh
			Append row
			.irow = Get number of rows
			Set string value:  .irow, "type", .type$
			Set numeric value: .irow, "vpx1", .vpx1
			Set numeric value: .irow, "vpx2", .vpx2
			Set numeric value: .irow, "vpy1", .vpy1
			Set numeric value: .irow, "vpy2", .vpy2
			Set numeric value: .irow, "x1", .x1
			Set numeric value: .irow, "x2", .x2
			Set numeric value: .irow, "y1", .y1
			Set numeric value: .irow, "y2", .y2
			Set numeric value: .irow, "nbuttons", .nbuttons
			Set numeric value: .irow, "ibutton", .ibutton
			Set numeric value: .irow, "mark", 0
			Set numeric value: .irow, "xon", .xon
			Set numeric value: .irow, "clicked", 0
			.ibutton += 1
		endfor
	endfor
endproc

procedure buttons_init_labels: .type$, .size, .labels$
	@buttons_findFirst: .type$
	.irow = buttons_findFirst.irow
	if .irow = 0
		exitScript: "Type " + .type$ + " not found."
	endif
	.nbuttons = object [buttons, .irow, "nbuttons"]
	@get_items: .labels$
	.nitems = get_items.nitems
	if .nitems <> .nbuttons
		exitScript: "Not enough labels for " + .type$
	endif
	for .i to .nbuttons
		.label$ = get_items.item$ [.i]
		@parse_two: .label$
		Set string value: .irow, "label", parse_two.p2$
		Set string value: .irow,  "label_id", parse_two.p1$
		Set numeric value: .irow, "size", .size
		.irow += 1
	endfor
endproc

# which button was clicked?

procedure buttons_checkClickedIn
	selectObject: buttons
	.nrows = Get number of rows
	for .irow to .nrows
		demo Select inner viewport: object [buttons, .irow,"vpx1"], object [buttons, .irow,"vpx2"], object [buttons, .irow,"vpy1"], object [buttons, .irow,"vpy2"]
		demo Axes: object [buttons, .irow,"vpx1"], object [buttons, .irow,"vpx2"], object [buttons, .irow,"vpy1"], object [buttons, .irow,"vpy2"]
		Set numeric value: .irow, "clicked", 0
		if demoClickedIn (object [buttons, .irow,"x1"], object [buttons, .irow,"x2"], object [buttons, .irow,"y1"], object [buttons, .irow,"y2"])
			.type$ = object$ [buttons, .irow,"type"]
			.ibutton = object [buttons, .irow,"ibutton"]
			.label_id$ = object$ [buttons, .irow,"label_id"]
			if object [buttons, .irow,"xon"] <> 0
				@buttons_set_one_mark_xon: .type$, .ibutton
			endif
			Set numeric value: .irow, "clicked", 1
		endif
	endfor  
endproc

# find index of first row for button type

procedure buttons_findFirst: .type$
	selectObject: buttons
	.nrows = Get number of rows
	.irow = 0
	repeat
		.irow += 1 
	until  .irow > .nrows || object$ [buttons, .irow, "type"] = .type$
	if .irow > .nrows
		.irow = 0
	endif  
endproc

# find which button is on for button type (one one may active at any time!)

procedure buttons_find_mark_on: .type$
	@buttons_findFirst: .type$
	.irow = buttons_findFirst.irow
	@debug: "buttons_find_mark_on: " + .type$ + " " + string$ (.irow)
	if .irow = 0
		exitScript: "Type " + .type$ +" not found."
	endif
	.iend = .irow + object [buttons, .irow, "nbuttons"] - 1
	.irow -= 1
	repeat
		.irow += 1
	until .irow > .iend or object [buttons, .irow, "mark"] <> 0
	if .irow > .iend
		.irow = 0
	endif
endproc

# Set one button value for type

procedure buttons_set_one_mark: .type$, .index, .value
	if .index != 0
		@buttons_findFirst: .type$
		.irow = buttons_findFirst.irow
		if .irow = 0
			exitScript: "Type " + .type$ + " not found."
		endif
		if .index > object [buttons, .irow, "nbuttons"]
			exitScript: "Index " + string$ (.index) + " larger than number of buttons for " + .type$
		endif
		Set numeric value: .irow+.index-1, "mark", .value
	endif
endproc

# Set an exclusive button for type

procedure buttons_set_one_mark_xon: .type$, .index
	@buttons_set_marks: .type$, 0
	@buttons_set_one_mark: .type$, .index, 1
endproc

# saves some typing 
procedure debug: .string$
	if debug
		appendInfoLine: .string$
	endif
endproc

procedure buttons_set_marks: .type$, .value
	@buttons_findFirst: .type$
	.irow = buttons_findFirst.irow
	if .irow = 0
		exitScript: "Type ", + .type$ + " not found."
	endif
	.nbuttons = object [buttons, .irow,"nbuttons" ]
	for .i from .irow to .irow + .nbuttons - 1
		Set numeric value: .i, "mark", .value
	endfor
endproc

# draw all the buttons
# if label_id matches ^^proc then call procedure proc for drawing

procedure buttons_draw
	selectObject: buttons
	.nrows = Get number of rows
	for .irow to .nrows
		selectObject: buttons
		.x1 = object [buttons, .irow, "x1"]
		.x2 = object [buttons, .irow, "x2"]
		.y1 = object [buttons, .irow, "y1"]
		.y2 = object [buttons, .irow, "y2"]
		.label_id$ = object$ [buttons, .irow, "label_id"]
		if index (.label_id$, label_is_procedure$) = 1
			.proc$ = replace$ (.label_id$, label_is_procedure$, "", 1)
			@'.proc$': .irow, .x1, .x2, .y1, .y2
		else
			@one_button_draw: .irow, .x1, .x2, .y1, .y2
		endif
	endfor
endproc

procedure one_button_draw: .irow, .vpx1, .vpx2, .vpy1, .vpy2
	demo Select inner viewport: .vpx1, .vpx2, .vpy1, .vpy2
	demo Axes: .vpx1, .vpx2, .vpy1, .vpy2
	demo Colour: color_parameter$
	demo Draw rounded rectangle: .vpx1, .vpx2, .vpy1, .vpy2, 3
	if object [buttons, .irow, "mark"] = 0
		demo Colour: color_normal$
		demo Line width: 2
	endif
	.label$ = object$ [buttons, .irow, "label"]
	demo Font size: object [buttons, .irow, "size"]
	demo Text: (.vpx1+.vpx2)/2, "Centre", (.vpy1+.vpy2)/2, "Half", .label$
	demo Line width: 1
	demo Font size: 16
endproc

# given amplitude:A frequency:f phase:\fi
# rewrite amplitude*sin(2*pi*frequency*x+phase) as {1:A}.sin(2.\pi.{2:f}.x+{3:\fi})
# or substitute the values 3, 200, 0 as {1:3}.sin(2.\pi.{2:200}.x+{3:0})
# we need this for highlighting specific parameters
# The procedure can be used to either substitute the alternative (:p) or the numerical value

procedure function_rewrite: .subst_value, .x_is_par, .cosmetic, .function_in$
	.function_out$ = .function_in$
	.npars = nparameters
	if .x_is_par
		.npars += 1
	endif
	.pari = 0
	for .i to .npars
		.parmi_i$ = parm_i$ [.i]
		if .subst_value
			.pari$ = parm_i$ [.i]
			if .i = nparameters + 1
				.pari = x_query
			else
				@debug: string$ (.i) + ":" + .pari$
				.pari = evaluate (.pari$)
			endif
			if abs(.pari) < precision
				.pari = 0
			endif
			.subi$ = fixed$ (.pari, 2)
		else
			.subi$ = parm_f$ [.i]
		endif
		.search$ = "(?<=^|\W)" + .parmi_i$ + "(?=\W|$)"
		if .cosmetic
			.replace$ = "%%{" + string$ (.i) + ":" + .subi$ + "}%\1"
		else
			.replace$ = "(" + .subi$ + ")\1"
		endif
		.function_out$ = replace_regex$ (.function_out$, .search$ , .replace$, 0)
		@debug: "function_rewrite: " + string$ (.i) + " " + .subi$ + " " + string$ (.pari) + " "+ .function_out$
	endfor
	if .cosmetic
		# improve the looks!
		.function_out$ = replace_regex$ (.function_out$, "(?<=^|\W)pi(?=\W|$)", "\\pi", 0)
		.function_out$ = replace_regex$ (.function_out$, "(?<=^|\W)x(?=\W|$)", "%%" + display_variable_x_as$+ "%", 0)
		.function_out$ = replace$ (.function_out$, "*", "\.c", 0)
	endif
endproc

# draw the rewritten formula with {1:p1}, ... with colors

procedure draw_colored: .xpos, .ypos, .xon, .formula$
	@buttons_findFirst: "parameter"
	.ifirst = buttons_findFirst.irow
	@buttons_find_mark_on: "parameter"
	.irow = buttons_find_mark_on.irow 
	.active = .irow - .ifirst + 1
	.form$ = .formula$
	.length = length (.form$)
	.hc = index (.form$, "}")
	.i = 1
	repeat
		.ho = index (.form$, "{")
		if .ho > 0
			.normal$ = mid$ (.form$, .i, .ho - .i)
			.dp = index (.form$, ":")
			.ipar$ = mid$ (.form$, .ho + 1, .dp - .ho -1)
			.hc = index (.form$, "}")
			.par$ = mid$ (.form$, .dp + 1, .hc - .dp - 1)
			.form$ = replace_regex$ (.form$, "\{|\}|:", "=", 3)
			.i = .hc + 1
			.tw = demo Text width (wc): .normal$
			demo Colour: color_normal$
			demo Text: .xpos, "Left", .ypos, "Half", .normal$
			.xpos += .tw
			.tw = demo Text width (wc): .par$
			demo Colour: color_normal$
			if number (.ipar$) = .active
				demo Colour: color_parameter$
			elsif number (.ipar$) = nparameters + 1
				demo Colour: color_query_link$
			endif
			demo Text: .xpos, "Left", .ypos, "Half", .par$
			.xpos += .tw
		else
			.normal$ = right$ (.form$, .length - .i + 1)
			demo Colour: color_normal$
			demo Text: .xpos, "Left", .ypos, "Half", .normal$    
		endif 
	until .ho = 0
endproc

# the numeric evaluation with some extras "y =  <rewrittenformula> = <result>"

procedure formula_draw_numeric: .irow, .vpx1, .vpx2, .vpy1, .vpy2
	demo Select inner viewport: .vpx1, .vpx2, .vpy1, .vpy2
	demo Axes: .vpx1, .vpx2, .vpy1, .vpy2
	@function_rewrite: 1, function_query, 1, "y(x)=" + function$
	function_r$ = function_rewrite.function_out$ 
	@debug: string$ (function_query) + " " + function_r$
	.xpos = .vpx1
	.ypos = (.vpy1 + .vpy2) / 2
	demo Font size: 24
	if function_query
		function_r$ = function_r$ + "= "
	endif
	@draw_colored: .xpos, .ypos, function_query, function_r$
	if function_query
		if abs(y_query) < precision
			y_query = 0
		endif
		.y_query$ = fixed$ (y_query, 2)
		.function_clean$ = replace_regex$ (function_r$, "\{\d+:([^{:]+)\}", "\1", 0)
		.tw = demo Text width (wc): .function_clean$
		.xpos += .tw
		demo Colour: color_query_link$
		demo Text: .xpos, "Left", .ypos, "Half", .y_query$
		demo Colour: color_normal$
	endif
endproc

procedure formula_draw: .irow, .vpx1, .vpx2, .vpy1, .vpy2
	demo Select inner viewport: .vpx1, .vpx2, .vpy1, .vpy2
	demo Axes: .vpx1, .vpx2, .vpy1, .vpy2
	@function_rewrite: 0, function_query, 1, "y(x)=" + function$
	function_r$ = function_rewrite.function_out$ 
	@debug: function_r$
	.xpos = .vpx1
	.ypos = (.vpy1 + .vpy2) / 2
	demo Font size: 24
	@draw_colored: .xpos, .ypos, 0, function_r$
endproc