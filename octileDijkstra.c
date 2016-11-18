#define INF 1e9
#define cc 100000
#define dc cc*1.4142135623731


#include <stdio.h>
#include <stdlib.h>
#include "octileDijkstra.h"
#include "minHeap.h"

/* Dijkstra SSSP for octile map */
void octileDijkstra( int* map, int *dist, int dim_x, int dim_y, 
               int state_x, int state_y)
{
    int i;

    /* Mark each state in map with INF */
    for ( i = 0; i < dim_x * dim_y; i++ )
    {
        dist[i] = INF;
    }

    /* Set source to 0 */
    dist[ state_x * dim_y + state_y ] = 0;

    /* Make a heap of all states 0..numStates-1, sorted by dist */
    MinHeap* queue = initMinHeap( dist, dim_x * dim_y );

    /* While queue is not empty... */
    while( queue->size > 0 )
    {
        /* u is index of state with smallest dist */
        int u = popMinHeap( queue );

        /* printf("%d\n", dist[u] ); */

        int u_x = u / dim_y;
        int u_y = u % dim_y;

        if (dist[u] == INF)
        {
            break;
        }
            /* all remaining states innaccesible (why not return?)*/
        
        /* for each neighbor of u.... ******************************/
        /* UNROLLED LOOP */
        int alt;

        /* NOTE: We can assume non-border condition probably */
        if( u_y > 0 && map[ u_x * dim_y + u_y - 1]==0 ) /* up */
        {
            alt = dist[ u_x * dim_y + u_y ] + cc;
            if (alt < dist[ u_x * dim_y + u_y - 1] )
                updateHeapElem( queue,
                                u_x * dim_y + u_y - 1,
                                alt );
        }
        if( u_y < dim_y && map[ u_x * dim_y + u_y + 1]==0  ) /* down */
        {
            alt = dist[ u_x * dim_y + u_y ] + cc;
            if (alt < dist[ u_x * dim_y + u_y + 1] )
                updateHeapElem( queue,
                                u_x * dim_y + u_y + 1,
                                alt );
        }
        if( u_x > 0 && map[ (u_x-1) * dim_y + u_y ] ==0  ) /* left */
        {
            alt = dist[ u_x * dim_y + u_y ] + cc;
            if (alt < dist[ (u_x-1) * dim_y + u_y ] )
                updateHeapElem( queue,
                                (u_x-1) * dim_y + u_y,
                                alt );
        }
        if( u_x < dim_x && map[ (u_x+1) * dim_y + u_y ]==0  ) /* right */
        {
            alt = dist[ u_x * dim_y + u_y ] + cc;
            if (alt < dist[ (u_x+1) * dim_y + u_y ] )
                updateHeapElem( queue,
                                (u_x+1) * dim_y + u_y,
                                alt );
        }
            /* ----- diagonals... */
        if( u_x < dim_x && u_y < dim_y 
                && map[ (u_x+1) * dim_y + u_y + 1 ]==0  )
        {
            alt = dist[ u_x * dim_y + u_y ] + dc;
            if (alt < dist[ (u_x+1) * dim_y + u_y + 1 ] )
                updateHeapElem( queue,
                                (u_x+1) * dim_y + u_y + 1,
                                alt );
        }
        if( u_x < dim_x && u_y > 0 
                && map[ (u_x+1) * dim_y + u_y - 1 ]==0  )
        {
            alt = dist[ u_x * dim_y + u_y ] + dc;
            if (alt < dist[ (u_x+1) * dim_y + u_y - 1 ] )
                updateHeapElem( queue,
                                (u_x+1) * dim_y + u_y - 1,
                                alt );
        }
        if( u_x > 0 && u_y < dim_y 
                && map[ (u_x-1) * dim_y + u_y + 1 ]==0  )
        {
            alt = dist[ u_x * dim_y + u_y ] + dc;
            if (alt < dist[ (u_x-1) * dim_y + u_y + 1 ] )
                updateHeapElem( queue,
                                (u_x-1) * dim_y + u_y + 1,
                                alt );
        }
        if( u_x > 0 && u_y > 0 
                && map[ (u_x-1) * dim_y + u_y - 1 ]==0  )
        {
            alt = dist[ u_x * dim_y + u_y ] + dc;
            if (alt < dist[ (u_x-1) * dim_y + u_y - 1 ] )
                updateHeapElem( queue,
                                (u_x-1) * dim_y + u_y - 1,
                                alt );
        }

    }

    deleteMinHeap( queue );
}
