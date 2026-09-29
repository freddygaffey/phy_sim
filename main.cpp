#include "stdio.h"
#include <cstdlib>
#include "raylib/src/raylib.h"

#define MAX_EDGE_CNT 1000

float scrMinX = 0;
float scrMaxX = 4000;
float scrMinY = 0;
float scrMaxY = 4000;
int canvasMaxX = 1000;
int canvasMaxY = 1000;

struct vtx {
  vtx* next;
  vtx* prev;
  int x;
  int y;

  vtx(int _x, int _y, vtx* _prev = nullptr, vtx* _next = nullptr){
    x = _x;
    y = _y;
    next = nullptr;
    prev = nullptr;
  };
};

class poly {
  public:
    vtx* origin;
    bool cw;
    double area;

  poly(int* point, int point_count){
    if (point_count < 3) {
      printf("commiting suiside\n");
      printf("^c ples");
      while (1);
    }
    vtx* _origin = (vtx*) malloc(sizeof(vtx)*point_count);
     
    *(_origin) = vtx(*(point+0),*(point+1),(_origin+point_count),(_origin+1));

    for (int i = 1; i < (point_count-1)*2; i = i + 2) {
      *(_origin+i) = vtx(*(point+i),*(point+i+1),(_origin-1),(_origin+1));
    }
    *(_origin+point_count) = vtx(*(point+point_count*2 -1 ),*(point+point_count*2),(_origin+point_count),(_origin));
    origin = _origin;
  };


  int validate(vtx* _origin,bool print = false){
    vtx* next = _origin->next;
    for (int i = 0; i < MAX_EDGE_CNT; i++){
      if (print == true) {
        printf("%d,%d\n",next->x,next->y);
      }
      if (next == _origin){
        return i;
      }
      next = next->next;
    };

    return -1;
  };
};

bool drawVtx(vtx* vertex, float rad = 5)
{ 
  printf("%d: %d: %d \n", ((vertex->x)), scrMinX, scrMaxX);
  DrawCircle(((1.0*(vertex->x))-scrMinX)/scrMaxX * canvasMaxX, (1.0*(vertex->y) - scrMinY)/scrMaxY * canvasMaxY, rad, RED);
  return true;
}

bool drawPoly(poly* polygon, float ran = 5, float thick = 2){
  vtx* c_vtx = polygon->origin;
  do{
    drawVtx(c_vtx);
    c_vtx = c_vtx->next;
    DrawLine(c_vtx->x,c_vtx->y,c_vtx->next->x,c_vtx->next->y,BLUE);

  } while (c_vtx->next != polygon->origin);
  return true;
  

}


int main(){

  InitWindow(canvasMaxX, canvasMaxY, "raylib example - basic window");
  // vtx test = vtx(2000, 2000);
  int _p[3][2] = {{0,0}, {1,1}, {1,0}};
  int (*p)[2] = &_p[0];
  poly pollll = poly(p,3);

  //poly has_a_cracker = pol
    // void DrawPixel(int posX, int posY, Color color); // Draw a pixel using geometry [Can be slow, use with care]

    // void DrawCircle(int centerX, int centerY, float radius, Color color);
    //     void DrawLine(int startPosX, int startPosY, int endPosX, int endPosY, Color color);
    while (!WindowShouldClose())
    {
        BeginDrawing();
            ClearBackground(RAYWHITE);
            // for (int i = 0;i<1000;i++){
            //   DrawPixel(i, 100, BLACK);
            // }
            // drawVtx(_p);
            drawPoly(pollll);

        // DrawCircle(10, 10, 5, ORANGE);
            // DrawText("Congrats! You created your first window!", 190, 200, 20, LIGHTGRAY);
        EndDrawing();
    }

    CloseWindow();
  return 0;
  // poly(, int point_count) 
  // return 0;
}
