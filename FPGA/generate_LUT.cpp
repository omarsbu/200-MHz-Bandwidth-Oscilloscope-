#include <iostream>
#include <fstream>
#include <cmath>

using namespace std;
const double PI = 3.141593;

int main() 
{
	/* Gaussian PDF parameters */
	double pdf;	
	double mean = 0;	
	double std_dev = 1;

	int n = 4096;	// number of LUT addresses
	double dx = (4*std_dev) / n;	// resolution of LUT
	double ref;	// reference value for each quantizationlevel
	bool PDF_LUT[4096][12];	// LUT, 4096 element array of 12-bit boolean vectors

	/* Create Result File */
	ofstream lut;
	lut.open("pdf_lut.txt");
	//	lut << "address\tbyte value\tdecimal value\n";

	int x = 0;	// number of bytes per row in result file
	double temp;
	int address = 0;	// base LUT address

	/* Calculate all values within 2 standard deviations of mean */
	for (double i = (mean - 2*std_dev); i < (mean + 2*std_dev); i += dx)
	{
		pdf = exp( - ((i - mean) * (i - mean)) / (2 * std_dev * std_dev)) / (std_dev * sqrt(2 * PI)) ;		
		temp = pdf;

		for (int bit = 11; bit >= 0; bit--)
		{
			ref = pow(2, bit);	// reference = 2^n for bit n
			ref = ref / 4096;	// reference relative to full-scale value
			
			/* Assign bit value '1' or '0'*/
			if (pdf < ref)
			{
				PDF_LUT[address][bit] = 0;
			}
			else
			{
				PDF_LUT[address][bit] = 1;
				pdf = pdf - ref;
			}
		}

		//		lut << address << "\t\t";

		/* Write byte value in VHDL format to output file */

		lut << "\"";
		
		for (int k = 11; k >= 0; k--)
			lut << PDF_LUT[address][k];
		
		lut << "\",";
		x++;

		// Check if new line
		if (x == 10)
		{
			lut << endl;
			x = 0;
		}

		//		lut << "\t" << temp << endl;
		address++;	// increment address on each iteration
	}
	return 0;
}