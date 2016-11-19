#include "CImg.h"
#include <iostream>

using namespace cimg_library;

CImg<unsigned char> original;
CImg<unsigned char> text;
char color = 1;
int width;

extern "C" int* openimage(char* name) {
  try {
    original.load(name);
    if(!original.is_empty()){
      int dims[2];
      dims[0] = original.width();
      dims[1] = original.height();
      return dims;
    }
  } catch (const CImgException ex) {
    return 0;
  }
}

extern "C" int createtext(char* txt, int size) {
  text.draw_text(0, 0, txt, &color, 0, 1, size);
  width = text.width();
  text.clear();
  return width;
}

extern "C" void saveimage(char* txt, int size) {
  original.draw_text(0, 0, txt, &color, 0, 1, size);
  original.save("output.png");
}

extern "C" int cast(double num) {
  return (int)num;
}