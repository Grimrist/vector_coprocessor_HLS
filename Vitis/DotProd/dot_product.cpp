#include "dot_product.hpp"

/* Función TOP */
void dot_product(res_data_t *res, data_t A[N], data_t B[N])
{
    /* Particionado de arreglos */
    #pragma HLS ARRAY_PARTITION variable=A dim=1 factor=1024 type=cyclic
    #pragma HLS ARRAY_PARTITION variable=B dim=1 factor=1024 type=cyclic

    res_data_t acc = 0;

    /* Loop principal */
    MAIN_LOOP: for (int i = 0; i < N; i++) {
        #pragma HLS UNROLL factor=64
        acc += A[i] * B[i];
    }

    *res = acc;
}
