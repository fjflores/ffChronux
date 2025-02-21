function varargout = plotspecgram( S, t, f, plt )
% PLOTSPECGRAM spectrogram plot with options.
%
% Usage:
% plotspecgram( S, t, f, plt, Serr )
%
% Inputs:
% S: input vector as a function of time and frequency (t x f)
% t: t axis grid for plot. Default [1:size(X,1)]
% f: f axis grid for plot. Default. [1:size(X,2)]
% plt: 'linear' for linear spectral power. "log" for logarithmic spectral 
% power. "loglog" for logarithmic spectral power and logarithmic frequency.

% Serr: lower and upper confidence intervals for X1: lower/upper x t x f.
%




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

hAx = axes;
switch plt
    case "linear"
        imagesc( t, f, S' )
        barLeg = "power (uV^2)";
        axis xy

    case "log"
        imagesc( t, f, 10 * log10( S' ) )
        barLeg = "power (dB)";
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
        barLeg = "power (dB)";

end

ffcbar( gcf, gca, barLeg )

if nargout > 0
    varargout{ 1 } = hAx;

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

