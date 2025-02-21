function varargout = plotspecgram( S, t, f, plt )
% PLOTSPECGRAM spectrogram plot with options.
%
% Usage:
% plotspecgram( S, t, f, plt, Serr )
%
% Inputs:
% S: input vector as a function of time and frequency (t x f)
% t (optional): t axis grid for plot. Default 1:size(S,1)
% f (optional): f axis grid for plot. Default 1:size(S,2)
% plt: "linear" for linear spectral power. "log" for logarithmic spectral 
% power. "loglog" for logarithmic spectral power and logarithmic frequency.
% 
% Output:
% hAx (optional): Axes handle.
% 
% Example:
% fs = 100;              % Sampling frequency (Hz)
% t = 0 : 1/fs : 5;        % Time vector (0 to 10 seconds)
% f1 = 10;              % Frequency for the first 5 secs (Hz)
% f2 = 25;              % Frequency for the last 5 seconds (Hz)
% y = zeros( size( t ) );   % Initialize the signal
% y( t < 2.5 ) = sin( 2 * pi * f1 * t( t < 2.5 ) ); 
% y(t >= 2.5 ) = sin( 2 * pi * f2 * t( t >= 2.5 ) );
% params = struct( 'tapers', [ 3 5 ], 'Fs', fs );
% win = [ 0.5 0.05 ];
% [ S, tS, f ] = mtspecgramc( y, win, params );
% subplot( 2, 1, 1 )
% plot( t, y )
% subplot( 2, 1, 2 )
% plotspecgram( S, tS, f, "log" )

% Serr: lower and upper confidence intervals for X1: lower/upper x t x f.

if nargin < 1
    error( 'Need data' )

end

[ NT, NF ] = size( S );
if nargin < 2
    t = 1 : NT;

end

if nargin < 3
    f = 1 : NF;

end

if length( f ) ~= NF || length( t ) ~= NT
    error('axes grid and data have incompatible lengths');

end

if nargin < 4 || isempty( plt )
    plt = "logP";

end

plt = string( plt );
switch plt
    case "linear"
        imagesc( t, f, S' )
        axis xy

    case "log"
        imagesc( t, f, 10 * log10( S' ) )
        axis xy

    case "loglog"
        varInfo = whos( 'S' );
        byteSize = varInfo.bytes;

        if byteSize < 10e6
            t = t( 1 : 2 : end );
            S = S( 1 : 2 : end, : );
        
        elseif byteSize >= 10e6 && byteSize < 100e6 % greater than 100 MB decimate by 2.
            t = t( 1 : 6 : end );
            S = S( 1 : 6 : end, : );

        elseif byteSize >= 100e6 % greater than 100 MB decimate by 2.
            t = t( 1 : 10 : end );
            S = S( 1 : 10 : end, : );

        end

        pcolor( t, f, 10 * log10( S' ) )
        shading flat
        set( gca, "Yscale", "log" )

end

% ffcbar( gcf, gca, barLeg )

if nargout > 0
    varargout{ 1 } = gca;

end
hold off

% title( 'Spectrogram' )

% else
%    subplot( 311 )
%    imagesc( t, f, squeeze( Serr( 1, :, : ) )' )
%    axis xy
%    colorbar
%    title( 'Lower confidence' )
%
%    subplot( 312 )
%    imagesc( t, f, S' )
%    title( 'X' )
%    axis xy
%    colorbar
%
%    subplot( 313 )
%    imagesc( t, f, squeeze( Serr( 2, :, : ) )' )
%    axis xy
%    colorbar
%    title( 'Upper confidence' )

