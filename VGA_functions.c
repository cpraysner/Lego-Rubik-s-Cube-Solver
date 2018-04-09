
#include <stdio.h>
#include <stdbool.h>
#include <string.h> 

// global variables, still need to initialize the variables, all colours to false, first colour to true, and colour input counter to 0
bool blue;
bool red;
bool yellow;
bool white;
bool orange;
bool green;
bool firstColour;
int colourInputCounter;
char whiteCenterSide;
char greenCenterSide;
char blueCenterSide;
char orangeCenterSide;
char yellowCenterSide;
char redCenterSide;
char *outputConfiguration;



// function prototypes
void write_char(int x, int y, char c);
void write_pixel(int x, int y, short colour);
void clear_screen();
void print_background(int colour);
void start_screen();
void input_message_screen();
void configuration_prompt();
void colour_input_prompt();
void *_allocator(size_t element, size_t typeSize);
char * configuration_converter();
char *append(const char *input, const char c);
char red();
char green();
char blue();
char yellow();
char red();
char orange();
char white();
void received_message_screen();
void solved_screen();


int main () {
	bool solved = false;
	clear_screen();
	configuration_prompt();
	back(); // is this how you add the function?
	solved_screen();
	free(outputConfiguration);
	outputConfiguration = NULL;
	return 0;
}


void write_pixel(int x, int y, short colour) {
	volatile short *vga_addr = (volatile short*)(0x08000000 + (y << 10) + (x << 1));
	*vga_addr = colour;
}


void write_char(int x, int y, char c) {
	volatile char * character_buffer = (char *)(0x09000000 + (y << 7) + x);
	*character_buffer = c;
}


// set all pixel to black
// does not delete buffer
void clear_screen() {
	for (int x = 0; x < 320; x++) {
		for (int y = 0; y < 240; y++) {
			write_pixel(x, y, 0);
		}
	}
}


// import a mif later to change the background
void print_background(int colour) { 

	for (int i = 0; i < 320; i++) {
		for (int j = 0; j < 240; j++) {
			write_pixel(i, j, colour);
		}
	}

}


void start_screen() {
	char *prompt = "PRESS ENTER TO BEGIN";
	for (int i = 0; i < strlen(prompt); i++) {
		write_char(40 + i, 40, prompt[i]);
	}
}


void input_message_screen() {
	clear_screen();
	char *prompt = "PLEASE INPUT CUBE CONFIGURATION";
	for (int i = 0; i < strlen(prompt); i++) {
		write_char(40 + i, 40, prompt[i]);
	}

}

void configuration_prompt() {
	clear_screen();
	char *prompt = "WHAT IS THE COLOUR FOR THE CENRTAL PIECES ON EACH SIDE?\n 
		PLEASE INPUT SINGLE CHARACTERS WITH NO SPACE, IN THE ORDER OF FRONT, BACK, UP, DOWN, LEFT, RIGHT\n
		COLOUR CODE:\n
		RED = R\tGREEN = G\n
		BLUE = B\tYELLOW = Y\n
		WHITE = W\tORANGE = 0\n";
		for (int i = 0; i < strlen(prompt); i++) {
			write_char(40 + i, 20, prompt[i]);
		}
	blue = false;
	red = false;
	yellow = false;
	white = false;
	orange = false;
	green = false;
	firstColour = true;
	colourInputCounter = 0;
	outputConfiguration = NULL; //?
}

void colour_input_prompt() {
	clear_screen();
	char *prompt = "WHAT ARE THE COLOURS ON EACH SIDE?\n 
		PLEASE INPUT SINGLE CHARACTERS WITH NO SPACE, IN THE ORDER OF FRONT, BACK, UP, DOWN, LEFT, RIGHT\n
		INPUT COLOURS ON EACH SIDE, START FROM THE LEFT, FINISH TOP ROW AND MOVE TO THE BOTTOM, END AT BOTTOM RIGHT\n
		COLOUR CODE : \n
		RED = R\tGREEN = G\n
		BLUE = B\tYELLOW = Y\n
		WHITE = W\tORANGE = 0\n";
		for (int i = 0; i < strlen(prompt); i++) {
			write_char(40 + i, 20, prompt[i]);
		}
	blue = false;
	red = false;
	yellow = false;
	white = false;
	orange = false;
	green = false;
	firstColour = true;
	outputConfiguration = NULL; //?
}


char red() {
	red = true;
	blue = false;
	yellow = false;
	white = false;
	orange = false;
	green = false;
	colourInputCounter += 1;
	configuration_converter();
}
char green() {
	green = true;
	blue = false;
	red = false;
	yellow = false;
	white = false;
	orange = false;
	colourInputCounter += 1;
	configuration_converter();
}
char yellow() {
	yellow = true;
	blue = false;
	red = false;
	white = false;
	orange = false;
	green = false;
	colourInputCounter += 1; 
	configuration_converter();

}
char white() {
	white = true;
	blue = false;
	red = false;
	yellow = false;
	orange = false;
	green = false;
	colourInputCounter += 1;
	configuration_converter();
}
char blue() {
	blue = true;
	red = false;
	yellow = false;
	white = false;
	orange = false;
	green = false;
	colourInputCounter += 1;
	configuration_converter();
}
char orange(){
	orange = true;
	blue = false;
	red = false;
	yellow = false;
	white = false;
	green = false;
	colourInputCounter += 1;
	configuration_converter();
}

// STILL NEED TO ADD DISPLAYING THE COLOURS ON VNC
char * configuration_converter() {
	if (firstColour == true) {
		clear_screen();
	}

	if (colourInputCounter == 1) {
		if (white) {
			write_char(40 + 0, 40, 'W');
			whiteCenterSide = 'F';
			white = false;
		}
		else if (red) {
			write_char(40 + 0, 40, 'R');
			redCenterSide = 'F';
			red = false;
		}
		else if (green) {
			write_char(40 + 0, 40, 'G');
			greenCenterSide = 'F';
			green = false;
		}
		else if (blue) {
			write_char(40 + 0, 40, 'B');
			blueCenterSide = 'F';
			blue = false;
		}
		else if (yellow) {
			write_char(40 + 0, 40, 'Y');
			yellowCenterSide = 'F';
			yellow = false;
		}
		else if (orange) {
			write_char(40 + 0, 40, 'O');
			orangeCenterSide = 'F';
			orange = false;
		}
		firstColour = false;
	}
	else if (colourInputCounter == 2) {
		if (white) {
			write_char(40 + 1, 40, 'W');
			whiteCenterSide = 'B';
			white = false;
		}
		else if (red) {
			write_char(40 + 1, 40, 'R');
			redCenterSide = 'B';
			red = false;
		}
		else if (green) {
			write_char(40 + 1, 40, 'G');
			greenCenterSide = 'B';
			green = false;
		}
		else if (blue) {
			write_char(40 + 1, 40, 'B');
			blueCenterSide = 'B';
			blue = false;
		}
		else if (yellow) {
			write_char(40 + 1, 40, 'Y');
			yellowCenterSide = 'B';
			yellow = false;
		}
		else if (orange) {
			write_char(40 + 1, 40, 'O');
			orangeCenterSide = 'B';
			orange = false;
		}

	}
	else if (colourInputCounter == 3) {
		if (white) {
			write_char(40 + 2, 40, 'W');
			whiteCenterSide = 'L';
			white = false;
		}
		else if (red) {
			write_char(40 + 2, 40, 'R');
			redCenterSide = 'L';
			red = false;
		}
		else if (green) {
			write_char(40 + 2, 40, 'G');
			greenCenterSide = 'L';
			green = false;
		}
		else if (blue) {
			write_char(40 + 2, 40, 'B');
			blueCenterSide = 'L';
			blue = false;
		}
		else if (yellow) {
			write_char(40 + 2, 40, 'Y');
			yellowCenterSide = 'L';
			yellow = false;
		}
		else if (orange) {
			write_char(40 + 2, 40, 'O');
			orangeCenterSide = 'L';
			orange = false;
		}


	}
	else if (colourInputCounter == 4) {
		if (white) {
			write_char(40 + 3, 40, 'W');
			whiteCenterSide = 'R';
			white = false;
		}
		else if (red) {
			write_char(40 + 3, 40, 'R');
			redCenterSide = 'R';
			red = false;
		}
		else if (green) {
			write_char(40 + 3, 40, 'G');
			greenCenterSide = 'R';
			green = false;
		}
		else if (blue) {
			write_char(40 + 3, 40, 'B');
			blueCenterSide = 'R';
			blue = false;
		}
		else if (yellow) {
			write_char(40 + 3, 40, 'Y');
			yellowCenterSide = 'R';
			yellow = false;
		}
		else if (orange) {
			write_char(40 + 3, 40, 'O');
			orangeCenterSide = 'R';
			orange = false;
		}

	}
	else if (colourInputCounter == 5) {
		if (white) {
			write_char(40 + 4, 40, 'W');
			whiteCenterSide = 'U';
			white = false;
		}
		else if (red) {
			write_char(40 + 4, 40, 'R');
			redCenterSide = 'U';
			red = false;
		}
		else if (green) {
			write_char(40 + 4, 40, 'G');
			greenCenterSide = 'U';
			green = false;
		}
		else if (blue) {
			write_char(40 + 4, 40, 'B');
			blueCenterSide = 'U';
			blue = false;
		}
		else if (yellow) {
			write_char(40 + 4, 40, 'Y');
			yellowCenterSide = 'U';
			yellow = false;
		}
		else if (orange) {
			write_char(40 + 4, 40, 'O');
			orangeCenterSide = 'U';
			orange = false;
		}


	}
	else if (colourInputCounter == 6) {
		if (white) {
			write_char(40 + 5, 40, 'W');
			whiteCenterSide = 'D';
			white = false;
		}
		else if (red) {
			write_char(40 + 5, 40, 'R');
			redCenterSide = 'D';
			red = false;
		}
		else if (green) {
			write_char(40 + 5, 40, 'G');
			greenCenterSide = 'D';
			green = false;
		}
		else if (blue) {
			write_char(40 + 5, 40, 'B');
			blueCenterSide = 'D';
			blue = false;
		}
		else if (yellow) {
			write_char(40 + 5, 40, 'Y');
			yellowCenterSide = 'D';
			yellow = false;
		}
		else if (orange) {
			write_char(40 + 5, 40, 'O');
			orangeCenterSide = 'D';
			orange = false;
		}
		firstColour = ture;
		colour_input_prompt();
	}

	// this is where the user types in the colour on each side
	// this should probably push back a string?
	// remember to dealloc the string later in main (outputConfiguration), method see below
	// https://stackoverflow.com/questions/10279718/append-char-to-string-in-c

	if((colourInputCounter>6)&&(colourInputCounter<=60)) {
		firstColour = false;
		if (orange) {
			write_char(40 + i, 40, 'O');
			outputConfiguration = append(outputConfiguration, orangeCenterSide);
			orange = false;
		}
		else if (white) {
			write_char(40 + i, 40, 'W');
			outputConfiguration = append(outputConfiguration, whiteCenterSide);
			white = false;
		}
		else if (blue) {
			write_char(40 + i, 40, 'B');
			outputConfiguration = append(outputConfiguration, blueCenterSide);
			blue = false;
		}
		else if (yellow) {
			write_char(40 + i, 40, 'Y');
			outputConfiguration = append(outputConfiguration, yellowCenterSide);
			yellow = false;
		}
		else if (green) {
			write_char(40 + i, 40, 'G');
			outputConfiguration = append(outputConfiguration, greenCenterSide);
			green = false;
		}
		else if (red) {
			write_char(40 + i, 40, 'R');
			outputConfiguration = append(outputConfiguration, redCenterSide);
			red = false;
		}
	}
	if (colourInputCounter == 60) {
		return outputConfiguration;
	}

}


/** Allocator function (safe alloc) */
void *_allocator(size_t element, size_t typeSize)
{
	void *ptr = NULL;
	/* check alloc */
	if ((ptr = calloc(element, typeSize)) == NULL)
	{
		printf(ERR_MESSAGE__NO_MEM); exit(1);
	}
	/* return pointer */
	return ptr;
}

/** Append function (safe mode) */
char *append(const char *input, const char c)
{
	char *newString, *ptr;

	/* alloc */
	newString = allocator((strlen(input) + 2), char);
	/* Copy old string in new (with pointer) */
	ptr = newString;
	for (; *input; input++) { *ptr = *input; ptr++; }
	/* Copy char at end */
	*ptr = c;
	/* return new string (for dealloc use free().) */
	return newString;
}


// needs to dealloc in main
/* dealloc */
//free(newString);
//newString = NULL;




void received_message_screen() {
	clear_screen();
	char *prompt = "YOUR CONFIGURATION IS RECEIVED, PLEASE PLACE CUBE ON THE MACHINE AND PRESS ENTER TO START SOLVING";
	for (int i = 0; i < strlen(prompt); i++) {
		write_char(40 + i, 40, prompt[i]);
	}
}

void solved_screen() {
	clear_screen();
	char *prompt = "YOUR RUBICS CUBE IS SOLVED, PRESS ENTER TO SOLVE AGAIN";
	for (int i = 0; i < strlen(prompt); i++) {
		write_char(40 + i, 40, prompt[i]);
	}
}


