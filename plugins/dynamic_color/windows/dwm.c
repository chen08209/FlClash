#include <windows.h>

typedef struct COLORIZATIONPARAMS
{
    COLORREF clrColor;
    COLORREF clrAftGlow;
    UINT nIntensity;
    UINT clrAftGlowBal;
    UINT clrBlurBal;
    UINT clrGlassReflInt;
    BOOL fOpaque;
} COLORIZATIONPARAMS;

HRESULT (WINAPI *DwmGetColorizationParameters) (COLORIZATIONPARAMS *colorparam);