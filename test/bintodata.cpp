#include <cstdio>
#include <cstdlib>

int main(int argc, char *argv[])
{
	if (argc < 4) {
		puts("usage : bintodata bin ram1 ram2 startaddr");
		return 0;
	}
	FILE *fin = fopen(argv[1], "rb");
	FILE *fout1 = fopen(argv[2], "w");
	FILE *fout2 = fopen(argv[3], "w");
	unsigned startaddr;
	sscanf(argv[4], "%x", &startaddr);
	startaddr /= 4;
	
	for (int i = 0;; i++) {
		unsigned b;
		int sz = fread(&b, 4, 1, fin);
		if (sz == 0) break;
		unsigned hi = (b >> 16) & 0xFFFF;
		unsigned lo = b & 0xFFFF;
		fprintf(fout1, "%06x=%04x\n", i + startaddr, lo);
		fprintf(fout2, "%06x=%04x\n", i + startaddr, hi);
	}
}
