/* MEX function to solve Single Source Shortest Path problem with 
 * Dijkstra Alg.
 */

/* Compile as mex mexDijkstra.c octileDijkstra.c minHeap.c */

#include <stdlib.h>
#include <string.h>

#include "mex.h"            /* all MEX stuff */
#include "octileDijkstra.h"

#define INF 1e9
#define min( X, Y ) ( (X) < (Y) ? (X) : (Y) )

void mexFunction(int nlhs, mxArray *plhs[ ], int nrhs, const mxArray *prhs[ ]) 
{

    /* Check parameters -------------------------------------- */ 
    if ((nrhs != 3) || (nlhs != 1))
        mexErrMsgTxt("should be called as [dist] = mexDijkstra(map, goal_x, goal_y)");

    int *map_in = (int*) mxGetPr(prhs[0]); /* get map matrix */
    int g_x = (int) *mxGetPr(prhs[1]) - 1; /* get gx */
    int g_y = (int) *mxGetPr(prhs[2]) - 1; /* get gy */
    int dim_x = (int) mxGetDimensions(prhs[0])[1]; /* get width */
    int dim_y = (int) mxGetDimensions(prhs[0])[0]; /* get height */

    /* Prepare outputs **********************************************/
    plhs[0] = mxCreateNumericMatrix( dim_y, dim_x, mxINT32_CLASS, mxREAL);
    int *dist = (int*) mxGetPr(plhs[0]); /* distance matrix ptr */

    /* Copy map input *********************/
    int size = dim_x * dim_y * sizeof(int);
    int *map = (int*)malloc(size);
    memcpy( map, map_in, size );

    octileDijkstra( map, dist, dim_x, dim_y, g_x, g_y );

    /* Free allocated mem ******/
    free(map);

}
