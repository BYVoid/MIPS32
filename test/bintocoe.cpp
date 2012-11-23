#include <cstdio>
#include <cstdlib>

int main(int argc, char *argv[])
{
	if (argc < 3) {
		puts("usage : BINToCOE binfile coefile");
		return 0;
	}
	FILE *fin = fopen(argv[1], "rb");
	FILE *fout = fopen(argv[2], "w");
	
	fprintf(fout, "MEMORY_INITIALIZATION_RADIX=16;\n");
	fprintf(fout, "MEMORY_INITIALIZATION_VECTOR=\n");
	bool flag = false;
	int sz;
	while (true) {
		int b;
		sz = fread(&b, 4, 1, fin);
		if (sz == 0) break;
		if (flag) fprintf(fout, ",\n");
		flag = true;
		fprintf(fout, "%08x", b);
	}
	fprintf(fout, ";\n");
}
