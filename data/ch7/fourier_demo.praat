# fourier_demo.praat
# djmw 20161130, 20170217, 20181104, 201811202
#

demo demoWindowTitle ("Fourier synthesis and analysis")

true = 1
false = 0
component = 1 ; the variable has to be defined otherwise our input checks fail
backgroundColour = 0.95
amplitude_colour$ = "Red"
frequency_colour$ = "Blue"
timeShift_colour$ = "Green"
sound_colour$ = "Maroon"
spectrum_colour$ = sound_colour$
buttons_update = 0
fontSize_default = 18
fontSize_formula = 16
fontSize_small = 12
componentNumber_play = 0
componentNumber_spectrumPlay = 0
componentNumber_amplitude = 0
componentNumber_frequency = 0
componentNumber_timeShift = 0
commandKeyPressed = false
shiftKeyPressed = false
sound_VP_duration = 0.03
sound_duration = 0.5
sound = 0
sound_play_asynchronous = 1
generate_new_sound = true
autocorrelation_show = false
soundVP_height = if autocorrelation_show then 20 else 20 fi

spectrumVP_xOffset = 7
spectrumVP_yOffset = 5
spectrumVP_width = 28
spectrumVP_height = 20

spectrumVP_xmin = spectrumVP_xOffset
spectrumVP_xmax = spectrumVP_xmin + spectrumVP_width
spectrumVP_ymax = 100 - spectrumVP_yOffset
spectrumVP_ymin = spectrumVP_ymax - spectrumVP_height
spectrumVP_xClicked = -1
spectral_component_colour$ = "Blue"
spectrum_minimumFrequency = 50
spectrum_maximumFrequency = 1000
spectrum_xmin = spectrum_minimumFrequency
spectrum_xmax = spectrum_maximumFrequency

spectrumXScaleVP_xmin = spectrumVP_xmin
spectrumXScaleVP_xmax = spectrumVP_xmax
spectrumXScaleVP_ymax = spectrumVP_ymin
spectrumXScaleVP_ymin = spectrumVP_ymin - 4
spectrumXScale = 0 ; linear, 1 = log10

spectrumYScaleVP_xmin = 0 ; 
spectrumYScaleVP_xmax = spectrumVP_xmin
spectrumYScaleVP_ymin = spectrumVP_ymin
spectrumYScaleVP_ymax = spectrumVP_ymax
spectrumYScale = 0 ; linear, 1 = log10

soundVP_offsetFromSpectrumVP = 15
soundVP_width = 30
soundVP_yOffset = spectrumVP_yOffset
soundVP_height = spectrumVP_height
soundVP_xmin = spectrumVP_xmax + soundVP_offsetFromSpectrumVP
soundVP_xmax = soundVP_xmin + soundVP_width
soundVP_ymax = 100 - soundVP_yOffset
soundVP_ymin = soundVP_ymax - soundVP_height
soundVP_xClicked = -1; the viewport x of a click in the sound

optionsVP_xmax = 100
optionsVP_xmin = optionsVP_xmax - 10
optionsVP_ymax = 100
optionsVP_ymin = optionsVP_ymax - 5

quitVP_xmax = 100
quitVP_xmin = quitVP_xmax - 10
quitVP_ymax = 92.5
quitVP_ymin = quitVP_ymax - 5

# buttons 1 - 4 change the synthesis
# buttons 5 Play new synthesis

numberOfButtons = 5
button_colour = 0.9
button_title_colour$ = "Black"
button_title$ [1] = "Number of components"
button_var$ [1] = "number_of_components$"
maximumNumberOfComponents = 20
button_value$ [1] = "2"
button_value_colour$ [1] = "Black"
button_title$ [2] = "Amplitude of component (Pa)"
button_var$ [2] = "amplitude_of_component$"
button_value$ [2] = "1.0"
button_value_colour$ [2] = amplitude_colour$
button_title$ [3] = "Frequency of component (Hz)"
button_var$ [3] = "frequency_of_component$"
button_value$ [3] = "component*100.0"
button_value_colour$ [3] = frequency_colour$
button_title$ [4] = "Shift of component (0...1 period)"
button_var$ [4] = "shift_of_component$"
button_value$ [4] = "0.0"
button_value_colour$ [4] = timeShift_colour$
button_title$ [5] = "Play new / again"
button_value$ [5] = ""
button_value_colour$ [5] = "Black"

buttonVP_xoffset = 3
buttonVP_yOffset = 12
buttonVP_top = spectrumVP_ymin - buttonVP_yOffset
buttonVP_height = buttonVP_top / numberOfButtons 
for ibutton to numberOfButtons
	buttonVP_xmin [ibutton] = spectrumVP_xmin - buttonVP_xoffset
	buttonVP_xmax [ibutton] = spectrumVP_xmax + buttonVP_xoffset
	buttonVP_ymax [ibutton] = buttonVP_top - (ibutton - 1) * (buttonVP_height)
	buttonVP_ymin [ibutton] = buttonVP_ymax [ibutton] - buttonVP_height * 7/8
	button_value_old$ [ibutton] = button_value$ [ibutton]
endfor

# We register the components parts (amplitude, frequency, shift) in a Table
column$[1] = "a_formula"
column$[2] = "f_formula"
column$[3] = "s_formula"
column$[4] = "a_number"
column$[5] = "f_number"
column$[6] = "s_number"
column$[7] = "a_status"
column$[8] = "f_status"
column$[9] = "s_status"
columnNames$ = column$[1]
for icol from 2 to 9
	columnNames$ = columnNames$ + " " + column$[icol] 
endfor
components = Create Table with column names: "components", maximumNumberOfComponents, columnNames$
numberOfComponents = number (button_value$ [1])
for .ibutton from 2 to 4
	@update_componentInfo: .ibutton, button_value$ [.ibutton]
endfor

@sound_initialize

@setBackgroundColour
@setComponentsViewports
@sounds_draw
@spectrum_draw
@options_draw
@quit_draw
@buttons_draw

@getUserInput

procedure getUserInput
	while demoWaitForInput()
		demo Select inner viewport: 0, 100, 0, 100
		demo Axes: 0, 100, 0, 100
		.clicked = 0
		buttonNumber_clicked = 0
		optionsClicked = 0
		componentNumber_play = 0
		componentNumber_spectrumPlay = 0
		soundVP_xClicked = -1
		spectrumVP_xClicked = -1
		componentNumber_amplitude = 0
		componentNumber_frequency = 0
		componentNumber_timeShift = 0
		for .ibutton to numberOfButtons
			if demoClickedIn (buttonVP_xmin[.ibutton], buttonVP_xmax[.ibutton], buttonVP_ymin[.ibutton], buttonVP_ymax[.ibutton])
				buttonNumber_clicked = .ibutton
				.clicked = 1
				goto VIEWPORT_FOUND
			endif
		endfor
		for .component to min (numberOfComponents, maximumComponentsViewable)
			if demoClickedIn (component_vp_xmin [.component], component_vp_xmax [.component], 
				... component_vp_ymin [.component], component_vp_ymax [.component])
				componentNumber_play = .component
				.clicked = 1
				goto VIEWPORT_FOUND
			elsif demoClickedIn (formulaAmplitudeVP_xmin [.component], formulaAmplitudeVP_xmax [.component], 
				... formulaAmplitudeVP_ymin [.component], formulaAmplitudeVP_ymax [.component])
				componentNumber_amplitude = .component
				.clicked = 1
				goto VIEWPORT_FOUND
			elsif demoClickedIn (formulaFrequencyVP_xmin [.component], formulaFrequencyVP_xmax [.component], 
				... formulaFrequencyVP_ymin [.component], formulaFrequencyVP_ymax [.component])
				componentNumber_frequency = .component
				.clicked = 1
				goto VIEWPORT_FOUND
			elsif demoClickedIn (formulaTimeShiftVP_xmin [.component], formulaTimeShiftVP_xmax [.component], 
				... formulaTimeShiftVP_ymin [.component], formulaTimeShiftVP_ymax [.component])
				componentNumber_timeShift = .component
				.clicked = 1
				goto VIEWPORT_FOUND
			endif
		endfor

		if demoClickedIn (soundVP_xmin, soundVP_xmax, soundVP_ymin, soundVP_ymax)
			soundVP_xClicked = demoX ()
			.clicked = 1
		elsif demoClickedIn (spectrumVP_xmin, spectrumVP_xmax, spectrumVP_ymin, spectrumVP_ymax)
			spectrumVP_xClicked = demoX ()
			.clicked = 1
		elsif demoClickedIn (spectrumYScaleVP_xmin, spectrumYScaleVP_xmax, spectrumYScaleVP_ymin, spectrumYScaleVP_ymax)
			spectrumYScale = (spectrumYScale + 1) mod 2
			.clicked = 1
		elsif demoClickedIn (spectrumXScaleVP_xmin, spectrumXScaleVP_xmax, spectrumXScaleVP_ymin, spectrumXScaleVP_ymax)
			spectrumXScale = (spectrumXScale + 1) mod 2
			.clicked = 1
		elsif demoClickedIn (optionsVP_xmin, optionsVP_xmax, optionsVP_ymin, optionsVP_ymax)
			optionsClicked = 1
			.clicked = 1
		elsif demoClickedIn (quitVP_xmin, quitVP_xmax, quitVP_ymin, quitVP_ymax)
			@quit_demo
		endif
		if demoKeyPressed ()
			if demoKey$ () == "q" and demoCommandKeyPressed ()
				@quit_demo
			endif
		endif
	label VIEWPORT_FOUND
		shiftKeyPressed = demoShiftKeyPressed ()
		commandKeyPressed = demoCommandKeyPressed ()
		generate_new_sound = 0 ; 
		if buttonNumber_clicked > 0
			generate_new_sound = true
			if shiftKeyPressed > 0
				generate_new_sound = false
			endif
		endif
		;@getClickInfo
		if .clicked = 1
			@actions
		endif
	endwhile
endproc

procedure quit_demo
	removeObject: sound, components
	demo Erase all
	demo Red
	demo Axes: 0, 100, 0, 100
	demo Text special: 50, "centre", 50, "half", "Times", 24, "0", "You may close this window now."
	exitScript ()
endproc

procedure getClickInfo
	writeInfoLine: "generate_new_sound: ", generate_new_sound
	appendInfoLine: "buttonNumber_clicked:", buttonNumber_clicked
	appendInfoLine: "componentNumber_play: ", componentNumber_play
	appendInfoLine: "commandKeyPressed: ", commandKeyPressed
	appendInfoLine: "shiftKeyPressed: ", shiftKeyPressed
	appendInfoLine: "soundVP_xClicked: ", fixed$ (soundVP_xClicked, 1)
	appendInfoLine: "spectrumVP_xClicked: ", fixed$ (spectrumVP_xClicked, 1)
	appendInfoLine: "componentNumber_amplitude: ", componentNumber_amplitude
	appendInfoLine: "componentNumber_frequency: ", componentNumber_frequency
	appendInfoLine: "componentNumber_timeShift: ", componentNumber_timeShift
	appendInfoLine: "spectrumYScale: ", spectrumYScale
	appendInfoLine: "optionsClicked: ", optionsClicked
endproc

procedure setBackgroundColour
	demo Select inner viewport: 0, 100, 0, 100
	demo Paint rectangle: backgroundColour, 0, 100, 0, 100	
endproc

procedure sound_initialize
	if sound > 0
		removeObject: sound
	endif
	@synthesize: sound_duration, 1, numberOfComponents
	sound = selected("Sound")
endproc

procedure findNearestComponent: .frequency
	.minimumDistance = 20000
	.index = 0
	for .component to numberOfComponents
		.distance = abs (.frequency - frequency [.component])
		if .distance < .minimumDistance
			.minimumDistance = .distance
			.index = .component
		endif
	endfor
endproc

procedure getComponents
	selectObject: components
	for component to numberOfComponents

		.frequency_info$ = Table_components$ [component, "f_status"]
		if .frequency_info$ = "" or .frequency_info$ = "f"
			.frequency_formula$ = Table_components$ [component, "f_formula"]
			frequency  [component] = '.frequency_formula$'
		elsif .frequency_info$ = "n"
			frequency  [component] = Table_components [component, "f_number"]
		endif
		frequency = frequency  [component]; the variable frequency can be used in the amplitude calculation
		Set numeric value: component, "f_number", frequency [component]

		.amplitude_info$ = Table_components$ [component, "a_status"]
		if .amplitude_info$ = "" or .amplitude_info$ = "f"
			.amplitude_formula$ = Table_components$ [component, "a_formula"]
			amplitude [component] = '.amplitude_formula$'
		elsif .amplitude_info$ = "n"
			amplitude  [component] = Table_components [component, "a_number"]
		endif
		if frequency [component] < spectrum_minimumFrequency
			frequency [component] = spectrum_minimumFrequency
			amplitude [component] = 0
		endif
		amplitude = amplitude  [component] ; the variable amplitude can be used in the timeshift calculation
		Set numeric value: component, "a_number", amplitude [component]

		.timeShift_info$ = Table_components$ [component, "s_status"]
		if .timeShift_info$ = "" or .timeShift_info$ = "f"
			.timeShift_formula$ = Table_components$ [component, "s_formula"]
			.timeShift_value = '.timeShift_formula$'
			timeShiftFraction [component] = ('.timeShift_value') mod 1
		elsif .amplitude_info$ = "n"
			timeShiftFraction  [component] = Table_components [component, "s_number"]
		endif
		Set numeric value: component, "s_number", timeShiftFraction [component]

	endfor
endproc

procedure synthesize: .duration, .fromComponent, .toComponent
	soundje = Create Sound from formula: "s", 1, 0, .duration, 44100, "0.0"
	# the loop index must be named "component" because we may use it in the "Number of components" form
	if generate_new_sound
		@getComponents
	endif
	selectObject: soundje
	for .component from .fromComponent to .toComponent	
		.phase  = timeShiftFraction [.component] * 2 * pi
		Formula: "self + amplitude  [.component] * sin (2*pi*frequency  [.component]*x + .phase)"
	endfor
	generate_new_sound = 0
endproc

procedure synthesizeValueAtTime: .time, .fromComponent, .toComponent
	.value = 0
	for component from .fromComponent to .toComponent
		.phase   = timeShiftFraction [component] * 2 * pi
		.value += amplitude  [component] * sin (2 * pi * frequency  [component] * .time + .phase)
	endfor
endproc

procedure actions
	@buttons_update
	@options_update
	@spectrum_click_update
	@sound_initialize
	demo Erase all
	@setBackgroundColour
	@sounds_draw
	@spectrum_draw
	@buttons_draw
	@options_draw
	@quit_draw
	
	if componentNumber_play > 0 or buttonNumber_clicked = 5 or componentNumber_spectrumPlay > 0
		... or (soundVP_xClicked > 0 and shiftKeyPressed <= 0)
		@sound_play
	endif
endproc

procedure options_update
	if optionsClicked
		.old_fontSize_default = fontSize_default
		.old_fontSize_small = fontSize_small
		.old_fontSize_formula = fontSize_formula
		.old_sound_duration = sound_duration
		.old_sound_play_asynchronous = sound_play_asynchronous
		beginPause: "Options"
			positive: "Standard font size", .old_fontSize_default
			positive: "Small font size", .old_fontSize_small
			positive: "Formula font size", .old_fontSize_formula
			positive: "Sound duration", .old_sound_duration
			boolean: "Sound play asynchronous", .old_sound_play_asynchronous
		.clicked = endPause:  "Cancel", "OK", 2, 1
		if .clicked = 2
			fontSize_default = max (10, standard_font_size)
			fontSize_small = max (8, small_font_size)
			fontSize_formula = max (8, formula_font_size)
			sound_duration = min (1, sound_duration)
			sound_duration = max (0.03, sound_duration)
		else
			fontSize_default = .old_fontSize_default
			fontSize_small = .old_fontSize_small
			fontSize_formula = .old_fontSize_formula
			sound_duration = .old_sound_duration
			sound_play_asynchronous = .old_sound_play_asynchronous
		endif
	endif
endproc

procedure buttons_update
	if buttonNumber_clicked > 0 && buttonNumber_clicked < 5
		.input_error = false
		label INPUT_ERROR
		.old_value$ = button_value$ [buttonNumber_clicked]
		beginPause: button_title$ [buttonNumber_clicked]
			sentence: button_title$ [buttonNumber_clicked], .old_value$
		.clicked = endPause:  "Cancel", "OK", 2, 1
		if .clicked = 2
			buttonvar$ = button_var$ [buttonNumber_clicked]
			button_value$ [buttonNumber_clicked] = 'buttonvar$'
			if buttonNumber_clicked > 1
				@update_componentInfo: buttonNumber_clicked, button_value$ [buttonNumber_clicked]
				if update_componentInfo.error = true
					goto INPUT_ERROR
				endif
			else
				.number = evaluate_nocheck (button_value$ [1])
				if .number = undefined
					button_value$ [buttonNumber_clicked] = .old_value$
					goto INPUT_ERROR
				endif
				.numberOfComponents$ = button_value$ [1]
				numberOfComponents = '.numberOfComponents$'
				if numberOfComponents > maximumNumberOfComponents
					numberOfComponents = maximumNumberOfComponents
					button_value$ [1] = string$ (numberOfComponents)
				endif
				for .ibutton from 2 to 4
					@update_componentInfo: .ibutton, button_value$ [.ibutton]
				endfor
			endif
		else 
			.clicked = 1
			button_value$ [buttonNumber_clicked] =  .old_value$
			.input_error = false
		endif
	endif
endproc

procedure update_componentInfo: .buttonNumber, .string$
	.tokens = Create Strings as tokens: .string$
	.numberOfTokens = Get number of strings
	for .itoken to .numberOfTokens
		.string$ = Get string: .itoken
		.value = evaluate_nocheck (.string$)
		if .value = undefined
			appendInfoLine: .string$
			update_componentInfo.error = true
			goto END_UPDATE
		endif
		.token$ [.itoken] = .string$
	endfor
	update_componentInfo.error = false
	selectObject: components
	.column = .buttonNumber - 1
	for .ic to numberOfComponents
		.formula$ = .token$ [if .ic <= .numberOfTokens then .ic else .numberOfTokens fi]
		if .formula$ <> "f" and .formula$ <> "n"
			Set string value: .ic, column$ [.column ], .formula$
			Set string value: .ic, column$ [.column + 6], ""
		else
			Set string value: .ic, column$ [.column + 6], .formula$
		endif
	endfor
	label END_UPDATE
	removeObject: .tokens
endproc

procedure spectrum_click_update
	if spectrumVP_xClicked > 0
		# find nearest component
		.x = spectrum_xmin + (spectrum_xmax - spectrum_xmin) * (spectrumVP_xClicked - spectrumVP_xmin) / (spectrumVP_xmax -  spectrumVP_xmin)
		.frequency = if spectrumXScale = 1 then 10^.x else .x fi
		@findNearestComponent: .frequency
		componentNumber_spectrumPlay = findNearestComponent.index
	endif
endproc

procedure sound_play
	.copy = 0
	if componentNumber_play = 0 and componentNumber_spectrumPlay = 0
		selectObject: sound
		.copy = Copy: "copy"
		Scale peak: 0.99
	else
		.fromComponent = componentNumber_play
		.toComponent = componentNumber_play
		if componentNumber_play > 0
			.fromComponent = componentNumber_play
			.toComponent = componentNumber_play
			if componentNumber_play == maximumComponentsViewable and numberOfComponents > maximumComponentsViewable
				.toComponent = numberOfComponents
			endif
		elsif componentNumber_spectrumPlay > 0
			.fromComponent = componentNumber_spectrumPlay
			.toComponent = componentNumber_spectrumPlay
		endif
		@synthesize: sound_duration, .fromComponent, .toComponent
		.sound_component = selected ("Sound")
		if commandKeyPressed
			Scale peak: 0.99
		endif
	endif

	Fade in: 1, 0, 0.005, "no"
	Fade out: 1, sound_duration, -0.005, "yes"
	if sound_play_asynchronous
		asynchronous Play
	else
		Play
	endif
	if componentNumber_play > 0 or componentNumber_spectrumPlay
		removeObject: .sound_component
	endif
	if .copy > 0
		removeObject: .copy
	endif
endproc

procedure options_draw
	demo Font size: fontSize_default
	demo Select inner viewport: optionsVP_xmin, optionsVP_xmax, optionsVP_ymin, optionsVP_ymax
	demo Axes: 0, 1, 0, 1
	demo Paint rounded rectangle: button_colour, 0, 1, 0, 1, 3
	demo Draw rounded rectangle: 0, 1, 0, 1, 3
	demo Helvetica
	demo Colour: button_title_colour$
	demo Text: 0.5, "centre", 0.5, "half", "Options"
endproc

procedure quit_draw
	demo Font size: fontSize_default
	demo Select inner viewport: quitVP_xmin, quitVP_xmax, quitVP_ymin, quitVP_ymax
	demo Axes: 0, 1, 0, 1
	demo Paint rounded rectangle: button_colour, 0, 1, 0, 1, 3
	demo Draw rounded rectangle: 0, 1, 0, 1, 3
	demo Helvetica
	demo Colour: button_title_colour$
	demo Text: 0.5, "centre", 0.5, "half", "Quit"
endproc

procedure buttons_draw
	for .ibutton to numberOfButtons
		demo Font size: fontSize_default
		demo Select inner viewport: buttonVP_xmin [.ibutton], buttonVP_xmax [.ibutton], buttonVP_ymin [.ibutton], buttonVP_ymax [.ibutton]
		demo Axes: 0, 1, 0, 1
		demo Paint rounded rectangle: button_colour, 0, 1, 0, 1, 3
		demo Colour: button_value_colour$ [.ibutton]
		demo Line width: 2
		demo Draw rounded rectangle: 0, 1, 0, 1, 3
		demo Line width: 1
		demo Colour: button_title_colour$
		demo Helvetica
		demo Colour: button_title_colour$
		demo Text: 0.5, "centre", 17/30, "bottom", button_title$ [.ibutton]
		demo Courier
		demo Colour: button_value_colour$ [.ibutton]
		demo Text: 0.5, "centre", 14/30, "top", button_value$ [.ibutton]
	endfor
endproc

procedure setComponentsViewports
	maximumComponentsViewable = 8
	.components_top = soundVP_ymin - buttonVP_yOffset
	.components_height = .components_top / maximumComponentsViewable
	for .component to maximumComponentsViewable
		component_vp_xmin [.component] = soundVP_xmin
		component_vp_xmax [.component] = soundVP_xmax
		component_vp_ymax [.component] = .components_top - (.component - 1) * .components_height
		component_vp_ymin [.component] = component_vp_ymax [.component] - .components_height * 7/8
	endfor
endproc

procedure sounds_draw
	.xmin = soundVP_xmin
	.xmax = soundVP_xmax
	.formula_xmin = .xmax + 2
	.formula_xmax = 100
	.mark_amplitude = (soundVP_xClicked >= 0) and (shiftKeyPressed > 0)
	demo Font size: fontSize_default
	demo Select inner viewport: .xmin, .xmax, soundVP_ymin, soundVP_ymax
	selectObject: sound
	.minimum = Get minimum: 0, 0, "Parabolic"
	.maximum = Get maximum: 0, 0, "Parabolic"
	.extremum = if abs (.minimum) > abs (.maximum) then abs (.minimum) else abs (.maximum) endif
	.fixedPrecision = if .extremum <= 1 then 2 else 1 endif
	.maximum = .extremum
	.minimum = - .extremum
	demo Axes: 0, sound_VP_duration, .minimum, .maximum
	demo Paint rectangle: 1, 0, sound_VP_duration, .minimum, .maximum
	demo Colour: sound_colour$
	demo Line width: 2
	demo Helvetica
	demo Draw: 0, sound_VP_duration, .minimum, .maximum, "no", "Curve"
	demo Line width: 1
	demo One mark left: 0, "no", "yes", "yes", "0.0"
	demo One mark left: .minimum, "no", "yes", "no", fixed$ (.minimum, .fixedPrecision)
	demo One mark left: .maximum, "no", "yes", "no", fixed$ (.maximum, .fixedPrecision)
	demo Marks bottom every: 1, 0.01, "yes", "yes", "no"
	demo Text bottom: "yes", "Time (s)"
	demo Text left: "yes", "Sound pressure (Pa)"
	.textTop$ = "Synthesized sound (= c__1_"
	for .component from 2 to min (numberOfComponents, maximumComponentsViewable - 1)
		.textTop$ = .textTop$ + "+c__" + string$ (.component) + "_"
	endfor
	if numberOfComponents >= maximumComponentsViewable
		.textTop$ = .textTop$ + "+c__" + string$ (maximumComponentsViewable) + "_"
	endif
	if numberOfComponents > maximumComponentsViewable
		.textTop$ = .textTop$ + " + ... + c__" + string$ (numberOfComponents) + "_"
	endif
	.textTop$ = .textTop$ + ")"
	demo Text top: "no", .textTop$
	demo Draw inner box
	if .mark_amplitude > 0
		.time = sound_VP_duration * (soundVP_xClicked - soundVP_xmin) / (soundVP_xmax -  soundVP_xmin)
		.yvalue = Get value at time: 1, .time, "Linear"
		demo Paint circle (mm): button_value_colour$ [2],  .time, .yvalue, 2
	endif

	.partials_summary$ = ""
	for .component to min (numberOfComponents, maximumComponentsViewable)
		.ymin = component_vp_ymin [.component]
		.ymax = component_vp_ymax [.component]
		.componentIsInSum = .component >= maximumComponentsViewable and numberOfComponents > maximumComponentsViewable
		demo Select inner viewport: component_vp_xmin [.component], component_vp_xmax [.component], .ymin, .ymax
		demo Colour: "Black"
		demo Axes: 0, sound_VP_duration, -1, 1
		demo Paint rectangle: 1, 0, sound_VP_duration, -1, 1
		demo Line width: 0.5
		demo Marks bottom every: 1, 0.01, "no", "yes", "no"
		demo Line width: 1
		.toComponent = .component
		demo Solid line
		if .componentIsInSum > 0
			.toComponent = numberOfComponents
			demo Dotted line
			demo Text special: -0.001, "Right", 0, "half", "Helvetica", 16, "0.0", 
			... "c__8_...c__" + string$ (numberOfComponents) + "_"
		else
			demo Text special: -0.001, "Right", 0, "half", "Helvetica", 16, "0.0", "c__" + string$ (.component) + "_"
		endif
		@synthesize: sound_VP_duration, .component, .toComponent
		.sound_component = selected ("Sound")
		if .component = componentNumber_play or (.component = componentNumber_spectrumPlay and not  .componentIsInSum)
			demo Colour: spectral_component_colour$
			demo Line width: 4
			.xpos2 = - 0.0005
			.xpos1 = .xpos2 - sound_VP_duration * 4 / (soundVP_xmax - soundVP_xmin)
			demo Draw arrow: .xpos1, 0.8, .xpos2, 0.8
			demo Line width: 1
		endif
		demo Draw: 0, sound_VP_duration, -1, 1, "no", "Curve"
		if .component = componentNumber_play or .component = componentNumber_spectrumPlay
			demo Colour: "Black"
		endif
		demo Dotted line
		demo One mark left: 0, "no", "no", "yes", ""
		demo Line width: 1
		demo Solid line
		demo Draw rectangle: 0, sound_VP_duration, -1, 1
		if .mark_amplitude
			@synthesizeValueAtTime: .time, .component, .toComponent
			.ypos = synthesizeValueAtTime.value
			.ypos = if .ypos > 1 then 1 else .ypos fi
			.ypos = if .ypos < -1 then -1 else .ypos fi
			demo Paint circle (mm): button_value_colour$ [2],  .time, .ypos, 2
		endif
		if componentNumber_timeShift == .component
			# extend on the left with 
			demo Dotted line
			.shiftTime = timeShiftFraction [.component] / frequency [.component]
			.fraction_vp = .shiftTime / sound_VP_duration
			.xmax_shift = .xmin
			.xmin_shift = .xmax_shift - .fraction_vp * (.xmax - .xmin)
			demo Select inner viewport: .xmin_shift, .xmax_shift, .ymin, .ymax
			.startTime = (1 - timeShiftFraction [.component]) / frequency [.component]
			demo Axes: .startTime, .startTime + .shiftTime, -1, 1
			demo Draw: .startTime, .startTime + .shiftTime, -1, 1, "no", "Curve"
			demo Solid line
		endif
		removeObject: .sound_component
		@component_formula_draw: .formula_xmin, .formula_xmax, .ymin, .ymax, .component
	endfor
	if .mark_amplitude
		demo Select inner viewport: .xmin, .xmax, .ymin, soundVP_ymax
		demo Axes: 0, sound_VP_duration, -1, 1
		demo Colour: button_value_colour$ [2]
		demo One mark bottom: .time, "no", "no", "yes", fixed$ (.time, 4)
		demo Colour: "Black"
	endif
endproc

procedure setComponentFormulaViewportsOff: .component
	formulaAmplitudeVP_xmin [.component] = -200
	formulaAmplitudeVP_xmax [.component] = -100
	formulaAmplitudeVP_ymin [.component] = -200
	formulaAmplitudeVP_ymax [.component] = -100

	formulaFrequencyVP_xmin [.component] = -200
	formulaFrequencyVP_xmax [.component] = -100
	formulaFrequencyVP_ymin [.component] = -200
	formulaFrequencyVP_ymax [.component] = -100

	formulaTimeShiftVP_xmin [.component] = -200
	formulaTimeShiftVP_xmax [.component] = -100
	formulaTimeShiftVP_ymin [.component] = -200
	formulaTimeShiftVP_ymax [.component] = -100
endproc

procedure component_formula_draw: .xmin, .xmax, .ymin, .ymax, .component
	# the formula as parts of differently coloured text
	demo Font size: fontSize_formula
	demo Select inner viewport: .xmin, .xmax, .ymin, .ymax
	demo Axes: .xmin, .xmax, .ymin, .ymax
	demo Helvetica
	.ymid = (.ymax + .ymin) / 2
	.ymin_textBox = .ymin + (.ymax - .ymin) / 4
	.ymax_textBox = .ymax - (.ymax - .ymin) / 4
	@setComponentFormulaViewportsOff: .component
	if .component == maximumComponentsViewable and numberOfComponents > maximumComponentsViewable
		.partials_summary$ = "Sum of c__" + string$ (.component) + "_ ... c__" + string$ (numberOfComponents) + "_"
		demo Text: .xmin, "Left", .ymid, "Half", .partials_summary$
	else
		.nwidth = demo Text width (world coordinates): "n"
		.nwidth3 = .nwidth / 3

		; amplitude sin (2\pi frequency t + 2\pi timeShiftFraction)

		.text_x = .xmin
		formulaAmplitudeVP_xmin [.component] = .text_x
		formulaAmplitudeVP_ymin  [.component] = .ymin_textBox
		formulaAmplitudeVP_ymax  [.component] = .ymax_textBox
		.text$ = fixed$ (amplitude[.component], if amplitude[.component] >= 1 then 1 else 2 fi)
		demo Colour: amplitude_colour$
		demo Text: .text_x, "Left", .ymid, "Half", .text$
		.text_width = demo Text width (world coordinates): .text$
		.text_x +=  .text_width + 0.5 * .nwidth3
		formulaAmplitudeVP_xmax [.component] = .text_x
	;appendInfoLine: formulaAmplitudeVP_xmin [.component], " ", formulaAmplitudeVP_xmax [.component]
		; sin(2\pi

		.text$ = "sin(2\pi"
		demo Colour: "Black"
		demo Text: .text_x, "Left", .ymid, "Half", .text$
		.text_width = demo Text width (world coordinates): .text$
		.text_x += .text_width + 0.5 * .nwidth3

		; frequency

		formulaFrequencyVP_xmin [.component] = .text_x
		formulaFrequencyVP_ymin  [.component] = .ymin_textBox
		formulaFrequencyVP_ymax  [.component] = .ymax_textBox
		.text$ = fixed$ (frequency [.component], 0)
		demo Colour: frequency_colour$
		demo Text: .text_x, "Left", .ymid, "Half", .text$
		.text_width = demo Text width (world coordinates): .text$
		.text_x += .text_width + 0.5 * .nwidth3
		formulaFrequencyVP_xmax [.component] = .text_x

		; t

		.text$ = "%%t%"
		demo Colour: "Black"
		demo Text: .text_x, "Left", .ymid, "Half", .text$
		.text_width = demo Text width (world coordinates): .text$
		.text_x += .text_width

		; phase

		if timeShiftFraction [.component] <> 0
			.text$ = "+2\pi"
			demo Colour: "Black"
			demo Text: .text_x, "Left", .ymid, "Half", .text$
			.text_width = demo Text width (world coordinates): .text$

			.text_x += .text_width + 0.5 * .nwidth3
			formulaTimeShiftVP_xmin [.component] = .text_x
			formulaTimeShiftVP_ymin  [.component] = .ymin_textBox
			formulaTimeShiftVP_ymax  [.component] = .ymax_textBox
			.text$ = fixed$ (timeShiftFraction [.component], 2)
			demo Colour: timeShift_colour$
			demo Text: .text_x, "Left", .ymid, "Half", .text$
			.text_width = demo Text width (world coordinates): .text$
			.text_x += .text_width
			formulaTimeShiftVP_xmax [.component] = .text_x
		endif
		.text$ = ")"
		demo Colour: "Black"
		demo Text: .text_x, "Left", .ymid, "Half", .text$
	endif
	demo Font size: fontSize_default
	demo Helvetica
endproc

procedure spectrum_draw
	selectObject: sound
	demo Font size: fontSize_default
	demo Select inner viewport: spectrumVP_xmin, spectrumVP_xmax, spectrumVP_ymin, spectrumVP_ymax
	demo Helvetica

	spectrum_xmax = if spectrumXScale = 1 then log10 (spectrum_maximumFrequency) else spectrum_maximumFrequency fi
	spectrum_xmin = if spectrumXScale = 1 then log10 (spectrum_minimumFrequency) else spectrum_minimumFrequency fi
	spectrum_ymax = if spectrumYScale = 1 then 1 else 1.1 fi
	.power = -6
	spectrum_ymin = if spectrumYScale = 1 then .power else 0 fi

	demo Axes: spectrum_xmin, spectrum_xmax, spectrum_ymin, spectrum_ymax
	demo Paint rectangle: 1, spectrum_xmin, spectrum_xmax, spectrum_ymin, spectrum_ymax
	demo Line width: 2
	demo Colour: spectrum_colour$
	for .component to numberOfComponents
		.xpos = if spectrumXScale = 1 then log10 (frequency [.component]) else frequency [.component] fi
		if .xpos >= spectrum_xmin and .xpos <= spectrum_xmax
			.ypos = abs (amplitude [.component])
			if spectrumYScale = 1 
				.ypos = if .ypos < spectrum_ymin then spectrum_ymin else log10 (.ypos) fi
			endif
			demo Draw line: .xpos, spectrum_ymin, .xpos, .ypos
		endif
	endfor
	demo Colour: "Black"
	demo Line width: 1
	demo Draw inner box
	demo Text top: "no", "Spectrum" + (if spectrumXScale = 1 then " at basilar membrane" else "" fi)
	.arrowBase = spectrum_ymin - (spectrum_ymax - spectrum_ymin) * 0.3
	if spectrumYScale = 1
		.amplitude = 1
		demo One mark left: 0, "no", "yes", "no", "1"
		for .ymark from 2 to abs(.power)
			.amplitude /= 10
			demo One mark left: log10 (.amplitude), "no", "yes", "no", "10^^-"+string$ (.ymark - 1) + "^"
		endfor
	else
		demo One mark left: spectrum_ymin, "no", "yes", "no", "0.0"
		demo One mark left: 0.5, "no", "yes", "no", "0.5"
		demo One mark left: 1.0, "no", "yes", "no", "1.0"
	endif
	demo Text left: "yes", "Amplitude"
	demo One mark bottom: (if spectrumXScale = 1 then log10 (100) else 100 fi), "no", "yes", "no", "100.0"
	demo One mark bottom: spectrum_xmax, "no", "no", "no", "1000"
	demo One mark bottom: (if spectrumXScale = 1 then log10 (500) else 500 fi), "no", "no", "no", "500"
	for .xmark to 10
		.frequency = .xmark * 100
		.xpos = if spectrumXScale = 1 then log10 (.frequency) else .frequency fi
		demo One mark bottom: .xpos, "no", "yes", "no", ""
	endfor
	demo Text bottom: "yes", "Frequency (Hz)"
	
	if componentNumber_play > 0 || componentNumber_frequency > 0 || componentNumber_spectrumPlay > 0
		.fromComponent = if componentNumber_play > 0 then componentNumber_play else componentNumber_frequency fi
		.toComponent = if componentNumber_play > 0 then componentNumber_play else componentNumber_frequency fi
		if componentNumber_play == maximumComponentsViewable 
			.toComponent = numberOfComponents
		endif
		if componentNumber_spectrumPlay > 0
			.fromComponent = componentNumber_spectrumPlay
			.toComponent = componentNumber_spectrumPlay
		endif
		demo Colour: spectral_component_colour$
		demo Line width: 5
		for .component from .fromComponent to .toComponent
			.xpos = if spectrumXScale = 1 then log10 (frequency [.component]) else frequency [.component] fi
			demo Draw arrow: .xpos, .arrowBase, .xpos, spectrum_ymin
		endfor
		demo Line width: 1
		demo Colour: "Black"
	endif
	if componentNumber_amplitude > 0
		.toComponent = componentNumber_amplitude
		if componentNumber_amplitude == maximumComponentsViewable 
			.toComponent = numberOfComponents
		endif
		demo Colour: amplitude_colour$
		demo Line width: 5
		for .component from componentNumber_amplitude to .toComponent
			.xpos2 = if spectrumXScale = 1 then log10 (frequency [.component]) else frequency [.component] fi
			.xpos1 = .xpos2 + (spectrum_xmax - spectrum_xmin) / 20
			.ypos = if spectrumYScale = 1 then log10 (amplitude [.component]) else amplitude [.component] fi
			demo Draw arrow: .xpos1, .ypos + abs (.arrowBase), .xpos2, .ypos
		endfor
		demo Line width: 1
	endif
	spectrumVP_xClicked = -1
endproc
