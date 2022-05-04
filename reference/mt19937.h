#ifndef MT_H
#define MT_H

void init_genrand(unsigned long s);
void init_by_array(unsigned long init_key[], int key_length);
unsigned long genrand_int32(void);

void init_genrand64(unsigned long long seed);
void init_by_array64(unsigned long long init_key[],
                     unsigned long long key_length);
unsigned long long genrand64_int64(void);

double genrand_res53(void);

double genrand_real1(void);
double genrand_real2(void);
double genrand_real3(void);

double genrand64_real1(void);
double genrand64_real2(void);
double genrand64_real3(void);

#endif // MT_H
