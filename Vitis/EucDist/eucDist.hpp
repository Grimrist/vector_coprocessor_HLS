#pragma once

#include "ap_int.h"
#include <hls_math.h>

/* Parámetros de diseño */
#define N 1024
/* Tipos de datos optimizados */
typedef ap_uint<10> data_t;      
typedef ap_uint<30> acc_data_t;  
typedef ap_uint<16> res_data_t;  

/* Prototipo de la función TOP */
void eucDist(res_data_t *res, data_t A[N], data_t B[N]);