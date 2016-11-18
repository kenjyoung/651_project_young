#include "mexH.h"
#include <stdlib.h>     /* abs */

/* Heuristic distance */

#define max(x, y) ((x > y) ? x : y)
#define min(x, y) ((x < y) ? x : y)

#define float2int 100000
#define dc float2int*1.4142135623731

int h(unsigned int stateI, unsigned int x2, unsigned int y2, unsigned int height) {
    
    /* Calculate coordinates of stateI */
    unsigned int x1 = stateI / height;
    unsigned int y1 = stateI % height;
    
    int dx = abs(x1-x2);
    int dy = abs(y1-y2);
    
    /* Manhattan distance */
    /* return dx + dy; */
    
    /* Octile distance */
    return dc*min(dx, dy) + float2int*max(dx, dy) - float2int*min(dx, dy);

     /* Octile distance with cardinal costs */
    /* return 10*min(dx, dy) + 10*max(dx, dy) - 10*min(dx, dy); */
    
}
