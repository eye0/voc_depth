#include <math.h>
#include "mex.h"

// small value, used to avoid division by zero
#define eps 0.0001

static inline float min(float x, float y) { return (x <= y ? x : y); }
static inline float max(float x, float y) { return (x <= y ? y : x); }

static inline int min(int x, int y) { return (x <= y ? x : y); }
static inline int max(int x, int y) { return (x <= y ? y : x); }

// main function:
// takes normals
// returns normal features
mxArray *process(const mxArray *mximage, const mxArray *mxsbin, const mxArray *mxmeans) {
  double *im = (double *)mxGetPr(mximage);
  double *means = (double *)mxGetPr(mxmeans);
  const int *dims = mxGetDimensions(mximage);
  const int *dimmeans = mxGetDimensions(mxmeans);
  if (mxGetNumberOfDimensions(mximage) != 3 ||
      dims[2] != 3 ||
      mxGetClassID(mximage) != mxDOUBLE_CLASS ||
      mxGetNumberOfDimensions(mxmeans) != 2 ||
      dimmeans[1] != 3
  )
  mexErrMsgTxt("Invalid input");

  int sbin = (int)mxGetScalar(mxsbin);

  // memory for caching orientation histograms & their norms
  int blocks[2];
  blocks[0] = (int)round((double)dims[0]/(double)sbin);
  blocks[1] = (int)round((double)dims[1]/(double)sbin);
  float *hist = (float *)mxCalloc(blocks[0]*blocks[1]*dimmeans[0], sizeof(float));
  float *norm = (float *)mxCalloc(blocks[0]*blocks[1], sizeof(float));

  int out[3];
  out[0] = max(blocks[0]-2, 0);
  out[1] = max(blocks[1]-2, 0);
  out[2] = dimmeans[0];
  mxArray *mxfeat = mxCreateNumericArray(3, out, mxSINGLE_CLASS, mxREAL);
  float *feat = (float *)mxGetPr(mxfeat);

  int visible[2];
  visible[0] = blocks[0]*sbin;
  visible[1] = blocks[1]*sbin;
  
  for (int x = 1; x < visible[1]-1; x++) {
    for (int y = 1; y < visible[0]-1; y++) {
      double *s = im + min(x, dims[1]-2)*dims[0] + min(y, dims[0]-2);
      double n1 = *s;

      s += dims[0]*dims[1];
      double n2 = *s;

      s += dims[0]*dims[1];
      double n3 = *s;

      // snap to one of the means
      double best_dot = 0;
      int best_o = 0;
      for (int o = 0; o < dimmeans[0]; o++) {
        double *i1 = means + o;
        double *i2 = means + o + dimmeans[0];
        double *i3 = means + o + 2*dimmeans[0];
        double dot = *i1*n1 + *i2*n2 + *i3*n3;
        if (dot > best_dot) {
          best_dot = dot;
          best_o = o;
        }
      }

      // add to 4 histograms around pixel using linear interpolation
      double xp = ((double)x+0.5)/(double)sbin - 0.5;
      double yp = ((double)y+0.5)/(double)sbin - 0.5;
      int ixp = (int)floor(xp);
      int iyp = (int)floor(yp);
      double vx0 = xp-ixp;
      double vy0 = yp-iyp;
      double vx1 = 1.0-vx0;
      double vy1 = 1.0-vy0;

      if (ixp >= 0 && iyp >= 0) {
        *(hist + ixp*blocks[0] + iyp + best_o*blocks[0]*blocks[1]) += 
          vx1*vy1;
      }

      if (ixp+1 < blocks[1] && iyp >= 0) {
        *(hist + (ixp+1)*blocks[0] + iyp + best_o*blocks[0]*blocks[1]) += 
          vx0*vy1;
      }

      if (ixp >= 0 && iyp+1 < blocks[0]) {
        *(hist + ixp*blocks[0] + (iyp+1) + best_o*blocks[0]*blocks[1]) += 
          vx1*vy0;
      }

      if (ixp+1 < blocks[1] && iyp+1 < blocks[0]) {
        *(hist + (ixp+1)*blocks[0] + (iyp+1) + best_o*blocks[0]*blocks[1]) += 
          vx0*vy0;
      }
    }
  }
  for (int o = 0; o < dimmeans[0]; o++) {
    float *src = hist + o*blocks[0]*blocks[1];
    float *dst = norm;
    float *end = norm + blocks[1]*blocks[0];
    while (dst < end) {
      *(dst++) += (*src) * (*src);
      src++;
    }
  }

  // compute features
  for (int x = 0; x < out[1]; x++) {
    for (int y = 0; y < out[0]; y++) {
      float *dst = feat + x*out[0] + y;      
      float *src, *p, n1, n2, n3, n4;
      p = norm + (x+1)*blocks[0] + y+1;
      n1 = 1.0 / sqrt(*p + *(p+1) + *(p+blocks[0]) + *(p+blocks[0]+1) + eps);
      p = norm + (x+1)*blocks[0] + y;
      n2 = 1.0 / sqrt(*p + *(p+1) + *(p+blocks[0]) + *(p+blocks[0]+1) + eps);
      p = norm + x*blocks[0] + y+1;
      n3 = 1.0 / sqrt(*p + *(p+1) + *(p+blocks[0]) + *(p+blocks[0]+1) + eps);
      p = norm + x*blocks[0] + y;      
      n4 = 1.0 / sqrt(*p + *(p+1) + *(p+blocks[0]) + *(p+blocks[0]+1) + eps);

      src = hist + (x+1)*blocks[0] + (y+1);
      for (int o = 0; o < dimmeans[0]; o++) {
        float h1 = min(*src * n1, 0.2);
        float h2 = min(*src * n2, 0.2);
        float h3 = min(*src * n3, 0.2);
        float h4 = min(*src * n4, 0.2);
        *dst = 0.5 * (h1 + h2 + h3 + h4);
        dst += out[0]*out[1];
        src += blocks[0]*blocks[1];
      }
    }
  }
  mxFree(hist);
  mxFree(norm);
  return mxfeat;
}

// matlab entry point
// F = features_depth(image, bin, means)
// image should be color with double values
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) { 
  if (nrhs != 3)
    mexErrMsgTxt("Wrong number of inputs"); 
  if (nlhs != 1)
    mexErrMsgTxt("Wrong number of outputs");
  plhs[0] = process(prhs[0], prhs[1], prhs[2]);
}


