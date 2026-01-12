#include "eucDist.hpp"

void eucDist(res_data_t *res, data_t A[N], data_t B[N])
{
	#pragma HLS ARRAY_PARTITION variable=A type=cyclic dim=1 factor=1024
    #pragma HLS ARRAY_PARTITION variable=B type=cyclic dim=1 factor=1024 

    /* Acumulador */
    acc_data_t acc = 0;

    MAIN_LOOP:
    for (int i = 0; i < N; i++) {
        #pragma HLS UNROLL factor=128
        acc += (A[i]-B[i])*(A[i]-B[i]);
    }

    /* Raíz cuadrada */
    *res = hls::sqrt(acc);
}
