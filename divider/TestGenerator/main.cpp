#include <iostream>
#include <string>
#include <cstdlib>
#include <cstdio>
#include <sstream>
#include <ostream>
#include <fstream>

uint32_t randomUInt32()
{
	// generate a random 32-bit number in this way:
	// 1. determine a random number N of significant digits in the range from 1 to 32
	// 2. if N > 0, place 1 in the N-th position
	// 3. fill the rest positions by a random sequence of ones and zeroes.
	int n = 1 + rand() % 32; // n in tne range [1..32]
	if (n == 0)
	{
		return 0;
	}
	uint32_t result = (1 << n);
	for (int i = 0; i < n; i++)
	{
		result |= (rand() % 2) << i;
	}
	return result;
}

void printLine(std::ostream &out, bool sign, uint32_t x, uint32_t y)
{
	const int HEX_WIDTH = 8;
	const int DEC_WIDTH = 11;
	if (sign) 
	{
		// convert x and y to signed
		int32_t div, rem;
		int32_t sx = static_cast<int32_t>(x);
		int32_t sy = static_cast<int32_t>(y);
		if (sy == 0)
		{
			div = -1;
			rem = sx;
		}
		else if (sx == static_cast<int32_t>(0x80000000) && sy == -1)
		{
			div = static_cast<int32_t>(0x80000000);
			rem = 0;
		}
		else
		{
			div = sx / sy;
			rem = sx % sy;
		}
		out << "s ";
		out.fill('0');
		out.width(HEX_WIDTH);
		out << std::hex << x << " ";
		out.width(HEX_WIDTH);
		out << y << " ";
		out.width(HEX_WIDTH);
		out << static_cast<uint32_t>(div) << " ";
		out.width(HEX_WIDTH);
		out << static_cast<uint32_t>(rem);
		// also print a comment
		out << std::dec << " // signed   ";
		out.fill(' ');
		out.width(DEC_WIDTH);
		out << sx << " / ";
		out.width(DEC_WIDTH);
		out << sy << " = ";
		out.width(DEC_WIDTH);
		out << div << "; rem = ";
		out.width(DEC_WIDTH);
		out << rem << std::endl;
	}
	else
	{
		uint32_t div, rem;
		// x and y are unsigned
		if (y == 0)
		{
			div = 0xffffffff;
			rem = x;
		}
		else
		{
			div = x / y;
			rem = x % y;
		}
		out << "u ";
		out.fill('0');
		out.width(HEX_WIDTH);
		out << std::hex << x << " ";
		out.width(HEX_WIDTH);
		out << y << " ";
		out.width(HEX_WIDTH);
		out << div << " ";
		out.width(HEX_WIDTH);
		out << rem;
		// also print a comment
		out << " // unsigned ";
		out.fill(' ');
		out.width(DEC_WIDTH);
		out << std::dec << x << " / ";
		out.width(DEC_WIDTH);
		out << y << " = ";
		out.width(DEC_WIDTH);
		out << div << "; rem = ";
		out.width(DEC_WIDTH);
		out << rem << std::endl;
	}
}

enum valKind
{
	VK_ZERO = 0, VK_MIN_INT, VK_MAX_INT, VK_MAX_UINT,
	VK_LAST
};

unsigned long valKind2int32(valKind vk)
{
	unsigned long val32[VK_LAST] = { 0ul, 0x80000000ul, 0x7ffffffful, 0xfffffffful };
	return val32[vk];
}

int main()
{
	const int DEC_WIDTH = 11;
	std::ofstream testfile;
	testfile.open("test_file.txt");
	// test set 1
	for (int sign = 0; sign < 2; sign++)
	{
		for (int vk_i = VK_ZERO; vk_i < VK_LAST; vk_i++)
		{
			for (int vk_j = VK_ZERO; vk_j < VK_LAST; vk_j++)
			{
				valKind vk_x = static_cast<valKind>(vk_i);
				valKind vk_y = static_cast<valKind>(vk_j);
				unsigned long ul_x = valKind2int32(vk_x);
				unsigned long ul_y = valKind2int32(vk_y);
				printLine(testfile, (bool)sign, ul_x, ul_y);
			}
		}
	}
	// test set 2
	for (int vk_i = VK_ZERO; vk_i < VK_LAST; vk_i++)
	{
		for (int j = 0; j < 100; j++)
		{
			valKind vk_x = static_cast<valKind>(vk_i);
			bool sign = rand() % 2;
			printLine(testfile, sign, valKind2int32(vk_x), randomUInt32());
		}
	}
	// test set 3
	for (int vk_i = VK_ZERO; vk_i < VK_LAST; vk_i++)
	{
		for (int j = 0; j < 100; j++)
		{
			valKind vk_x = static_cast<valKind>(vk_i);
			bool sign = rand() % 2;
			printLine(testfile, sign, randomUInt32(), valKind2int32(vk_x));
		}
	}
	// random part
	for (int i = 0; i < 4000; i++)
	{
		bool sign = rand() % 2;
		printLine(testfile, sign, randomUInt32(), randomUInt32());
	}
	testfile.close();
	return 0;
}
