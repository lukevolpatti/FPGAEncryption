#include <stdint.h>
#include <iostream>
#include <chrono>
typedef std::chrono::high_resolution_clock Clock;
using namespace std;


void encrypt (uint32_t* v, uint32_t* k) {
    uint32_t v0=v[0], v1=v[1], sum=0, i;           /* set up */
    uint32_t delta=0x9e3779b9;                     /* a key schedule constant */
    uint32_t k0=k[0], k1=k[1], k2=k[2], k3=k[3];   /* cache key */
    for (i=0; i < 32; i++) {                       /* basic cycle start */
        sum += delta;
        v0 += ((v1<<4) + k0) ^ (v1 + sum) ^ ((v1>>5) + k1);
        v1 += ((v0<<4) + k2) ^ (v0 + sum) ^ ((v0>>5) + k3);
    }                                              /* end cycle */
    v[0]=v0; v[1]=v1;
}

void decrypt (uint32_t* v, uint32_t* k) {
    uint32_t v0=v[0], v1=v[1], sum=0xC6EF3720, i;  /* set up */
    uint32_t delta=0x9e3779b9;                     /* a key schedule constant */
    uint32_t k0=k[0], k1=k[1], k2=k[2], k3=k[3];   /* cache key */
    for (i=0; i<32; i++) {                         /* basic cycle start */
        v1 -= ((v0<<4) + k2) ^ (v0 + sum) ^ ((v0>>5) + k3);
        v0 -= ((v1<<4) + k0) ^ (v1 + sum) ^ ((v1>>5) + k1);
        sum -= delta;
    }                                              /* end cycle */
    v[0]=v0; v[1]=v1;
}

int main(){
    uint32_t v[2] = {1 , 1};
    uint32_t k[4] = {32, 324, 1232, 54};
    cout << "Original data: " << v[0] << " " << v[1] << endl;
    cout << "Key : " << k[0] << " " << k[1] << k[2] << " " << k[3] << endl;
    auto t1 = Clock::now();
    encrypt(v, k);
    auto t2 = Clock::now();
    cout << "Encrypted data: " << v[0] << " " << v[1] << endl;
    cout << "Key: " << k[0] << " " << k[1] << k[2] << " " << k[3] << endl;
    decrypt(v, k);
    cout << "Decrypted data: " << v[0] << " " << v[1] << endl;
    cout << "Key: " << k[0] << " " << k[1] << k[2] << " " << k[3] << endl;
    cout << "Delta t2-t1: " 
              << std::chrono::duration_cast<chrono::nanoseconds>(t2 - t1).count()
              << " nanoseconds" << std::endl;
}