
#include <stdio.h>
#include <stdbool.h>
#include <string.h> 


// function prototypes
void write_char(int x, int y, char c);
void write_pixel(int x, int y, short colour);
void clear_screen();
void print_background(int colour);
void start_screen();
void input_message_screen();
void received_message_screen();
void solved_screen();


int main () {
	bool solved = false;
	clear_screen();

	while (true) {
		print_background();
	}

	solved = false;
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