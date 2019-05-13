function nfft = getnfft( n, pad )
% GETNFFT gets the points in an fft given a padding factor.
% 
% Usage:
% nfft = getnfft( N, pad )
% 
% Input:
% n: length of data vector.
% pad: padding factor for the FFT. Can take values -1,0,1,2... 
% -1 corresponds to no padding, 0 corresponds to padding to the next 
% highest power of 2 etc. 
% e.g. For N = 500, if PAD = -1, we do not pad; if PAD = 0, we pad the FFT
% to 512 points, if pad=1, we pad to 1024 points etc. Default: 0.

if nargin == 1
    pad = 0;
    
end
    
nfft = max( 2 ^ ( nextpow2( n ) + pad ), n );