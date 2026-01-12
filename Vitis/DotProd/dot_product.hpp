/* Evita inclusión recursiva */
#pragma once

#include "ap_int.h"

/* Tamaño del vector */
#define N 1024

/* Ancho de bits */
#define BIT_WIDTH 10

/* Tipo de dato de entrada */
typedef ap_uint<BIT_WIDTH> data_t;

/* Tipo de dato de salida */
typedef ap_uint<30> res_data_t;

/* Declaración de función TOP */
void dot_product(res_data_t *res, data_t A[N], data_t B[N]);
