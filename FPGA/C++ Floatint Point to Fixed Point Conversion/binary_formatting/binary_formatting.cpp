#include <iostream>
#include <fstream>
#include <string>

int main() {
    /* Input file bit length is 64 bits */

    std::ifstream inputFile("Decimal_coefficients.txt");  // Input file with decimal coefficients
    std::ofstream outputFile("fixed_point_filter_coefficients.txt"); // Output file for truncated values

    bool fixed_point_coefficient[32];
    char hex_fixed_point_coefficient[8];
    int int_coeff;

    if (!inputFile || !outputFile) {
        std::cerr << "Error opening file!" << std::endl;
        return 1;
    }

    std::string line;
    while (std::getline(inputFile, line)) {
        float decimal_coefficient = std::stof(line); // Convert string to float

        if (decimal_coefficient < 0) {
            fixed_point_coefficient[31] = 1;
            int_coeff = (int)((1 - abs(decimal_coefficient)) * pow(2, 30));  // Convert to integer domain, multiply by 2^30
        }
        else {
            int_coeff = (int)(decimal_coefficient * pow(2, 30));  // Convert to integer domain, multiply by 2^30
            fixed_point_coefficient[31] = 0;
        }

        for (int i = 30; i >= 0; i--)
        {
            int ref = (int)pow(2, i);

            if (int_coeff > ref) {
                fixed_point_coefficient[i] = 1;
                int_coeff -= ref;
            }
            else
                fixed_point_coefficient[i] = 0;
        }

        // Convert binary array to hexadecimal and store in the array
        for (int i = 31; i >= 0; i -=4) {
            int value = 0;
            value += fixed_point_coefficient[i] * 8;
            value += fixed_point_coefficient[i-1] * 4;
            value += fixed_point_coefficient[i-2] * 2;
            value += fixed_point_coefficient[i-3] * 1;

            if (value == 0)
                hex_fixed_point_coefficient[((i + 1) / 4) - 1] = '0';
            else if (value == 1)
                hex_fixed_point_coefficient[((i + 1) / 4) - 1] = '1';
            else if (value == 2)
                hex_fixed_point_coefficient[((i + 1) / 4) - 1] = '2';
            else if (value == 3)
                hex_fixed_point_coefficient[((i + 1) / 4) - 1] = '3';
            else if (value == 4)
                hex_fixed_point_coefficient[((i + 1) / 4) - 1] = '4';
            else if (value == 5)
                hex_fixed_point_coefficient[((i + 1) / 4) - 1] = '5';
            else if (value == 6)
                hex_fixed_point_coefficient[((i + 1) / 4) - 1] = '6';
            else if (value == 7)
                hex_fixed_point_coefficient[((i + 1) / 4) - 1] = '7';
            else if (value == 8)
                hex_fixed_point_coefficient[((i + 1) / 4) - 1] = '8';
            else if (value == 9)
                hex_fixed_point_coefficient[((i + 1) / 4) - 1] = '9';
            else if(value == 10)
                hex_fixed_point_coefficient[((i + 1) / 4) - 1] = 'A';
            else if (value == 11)
                hex_fixed_point_coefficient[((i + 1) / 4) - 1] = 'B';
            else if (value == 12)
                hex_fixed_point_coefficient[((i + 1) / 4) - 1] = 'C';
            else if (value == 13)
                hex_fixed_point_coefficient[((i + 1) / 4) - 1] = 'D';
            else if (value == 14)
                hex_fixed_point_coefficient[((i + 1) / 4) - 1] = 'E';
            else if (value == 15)
                hex_fixed_point_coefficient[((i + 1) / 4) - 1] = 'F';
        }
        outputFile << '"';

        // Write the fixed-point coefficient to the output file
        for (int i = 7; i >= 0; i--) {
            outputFile << hex_fixed_point_coefficient[i];
        }
        outputFile << '"' << ',' << std::endl;

    }

    inputFile.close();
    outputFile.close();

    return 0;
}
