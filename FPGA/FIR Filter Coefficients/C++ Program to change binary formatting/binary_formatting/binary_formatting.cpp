#include <iostream>
#include <fstream>
#include <string>

int main() {
    /* Input file bit length is 64 bits */

    std::ifstream inputFile("binary.txt");  // Input file with binary values
    std::ofstream outputFile("binary_filter_coefficients.txt"); // Output file for truncated values

    int n;  // Number of LSBs to truncate
    std::cout << "Enter bit width of coefficients: ";
    std::cin >> n;

    n = 64 - n;

    if (!inputFile || !outputFile) {
        std::cerr << "Error opening file!" << std::endl;
        return 1;
    }

    std::string line;
    while (std::getline(inputFile, line)) {
        // Truncate the last n bits by removing them from the string
        std::string truncatedLine = line.substr(0, line.size() - n);

        // Write the truncated line to the output file
        outputFile << truncatedLine << std::endl;
    }

    inputFile.close();
    outputFile.close();

    return 0;
}
