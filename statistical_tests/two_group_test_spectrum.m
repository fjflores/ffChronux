function [dz,vdz,Adz,conf]=two_group_test_spectrum(J1,J2,p,plt,f)
% function [dz,vdz,Adz]=two_group_test_spectrum(J1,J2,p,plt,f)
% Test the null hypothesis (H0) that data sets J1, J2 in 
% two conditions c1,c2 have equal population spectrum
%
% Usage:
% [ dz, vdz, Adz ] = two_group_test_spectrum( J1, J2, p )
%
% Inputs:
% J1   tapered fourier transform in condition 1
% J2   tapered fourier transform in condition 2
% p      p value for test (default: 0.05)
% plt    'y' for plot and 'n' for no plot
% f      frequencies (useful for plotting)
%
%
% Dimensions: J1: frequencies x number of samples in condition 1
%             J2: frequencies x number of samples in condition 2
%              number of samples = number of trials x number of tapers
% Outputs:
% dz    test statistic (will be distributed as N(0,1) under H0
% vdz   Arvesen estimate of the variance of dz
% Adz   1/0 for accept/reject null hypothesis of equal population
%       coherences based dz ~ N(0,1)
% 
% 
% Note: all outputs are functions of frequency
%
% References: Arvesen, Jackkknifing U-statistics, Annals of Mathematical
% Statistics, vol 40, no. 6, pg 2076-2100 (1969)

if nargin < 2
    error('Need two sets of Fourier transforms'); 
end

if nargin < 4 || isempty(plt)
    plt='n'; 
    
end

% Test for matching dimensionalities
m1 = size( J1, 2 ); % number of samples, condition 1
m2 = size( J2, 2 ); % number of samples, condition 2
dof1 = m1; % degrees of freedom, condition 1
dof2 = m2; % degrees of freedom, condition 2

if nargin < 5 || isempty(f)
    f = size( J1, 1 );
end

 % set the default p value
if nargin < 3 || isempty(p); 
    p = 0.05;
    
end

% Compute the individual condition spectra
S1 = conj( J1 ) .* J1; 
S2 = conj( J2 ) .* J2; 

Sm1 = squeeze( mean( S1, 2 ) ); 
Sm2 = squeeze( mean( S2, 2 ) ); 

% Compute the statistic dz, and the probability of observing the value dz
% given an N(0,1) distribution i.e. under the null hypothesis.
% bias from Thomson & Chave.
bias1 = psi( dof1 ) - log( dof1 );
bias2 = psi( dof2 ) - log( dof2 ); 

% Variance from Thomson & Chave.
var1 = psi( 1, dof1 ); 
var2 = psi( 1, dof2 ); 

% Bias-corrected Fisher z.
z1 = log( Sm1 ) - bias1; 
z2 = log( Sm2 ) - bias2;

% z statistic
dz = ( z1 - z2 ) / sqrt( var1 + var2 ); 

% probability of observing value dz
pdz = 2 * normcdf( -abs( dz ), 0, 1 ); 

% The remaining portion of the program computes Jackknife estimates of the 
% mean (mdz) and variance (vdz) of dz.
samples1 = 1 : m1;
samples2 = 1 : m2;

% Leave one out of one sample
bias11 = psi( dof1 - 1 ) - log( dof1 - 1 );
var11 = psi( 1, dof1 - 1 );
for i = 1 : m1
    % all samples except i
    ikeep = setdiff( samples1, i );
    
    % 1 drop mean spectrum, data 1, condition 1
    Sm1 = squeeze( mean( S1( :, ikeep ), 2 ) );
    
    % 1 drop, bias-corrected Fisher z, condition 1
    z1i( :, i ) = log( Sm1 ) - bias11;
    
    % 1 drop, z statistic, condition 1
    dz1i( :, i ) = ( z1i( :, i ) - z2 ) / sqrt( var11 + var2 ); 
    ps1( :, i ) = m1 * dz - ( m1 - 1 ) * dz1i( :, i );
    
end

ps1m = mean( ps1, 2 );
bias21 = psi( dof2 - 1 ) - log( dof2 - 1 );
var21 = psi( 1,dof2 - 1 );
for j = 1 : m2
    % all samples except j
    jkeep = setdiff( samples2, j );
    
    % 1 drop mean spectrum, data 2, condition 2
    Sm2 = squeeze( mean( S2( :, jkeep ), 2 ) ); 
    
    % 1 drop, bias-corrected Fisher z, condition 2
    z2j( :, j ) = log( Sm2 ) - bias21;
    
    % 1 drop, z statistic, condition 2
    dz2j( :, j ) = ( z1 - z2j( :, j ) ) / sqrt( var1 + var21 ); 
    ps2( :, j ) = m2 * dz - ( m2 - 1 ) * dz2j( :, j );
    
end

% Jackknife mean and variance
ps2m = mean( ps2, 2 );
vdz = sum(...
    ( ps1 - ps1m( :, ones( 1, m1 ) ) ) .*...
    ( ps1 - ps1m( :, ones( 1, m1 ) ) ), 2 ) /...
    ( m1 * ( m1 - 1) ) +...
    sum( ( ps2 - ps2m( :, ones( 1, m2 ) ) ) .*...
    ( ps2 - ps2m( :, ones( 1, m2 ) ) ), 2 ) / ( m2 *( m2 - 1 ) );

% Test whether H0 is accepted at the specified p value
Adz = zeros( size( dz ) );
x = norminv( [ p / 2 1 - p / 2 ], 0, 1 );
indx = find( dz >= x( 1 ) & dz <= x( 2 ) ); 
Adz( indx ) = 1;
conf = norminv( 1 - p / 2, 0, 1 );

if strcmp( plt, 'y' )
    if isempty( f ) || nargin < 5
        f = linspace( 0, 0.5, length( dz ) );
        
    end
    
    % Compute the spectra
    S1 = squeeze( mean( conj( J1 ) .* J1, 2 ) );
    S2 = squeeze( mean( conj( J2 ) .* J2, 2 ) );
    
    % Plot the spectra
    subplot( 3, 1, 1 ); 
    plot( f, 10 * log10( S1 ), f, 10 * log10( S2 ) ); 
    legend( 'Data 1', 'Data 2' );
    ylabel( 'Power (dB)' );
    title( 'Two group test for spectra' );
    
    subplot( 3, 1, 2 );
    x = [ f( 1 ) f( 1 ) f( end ) f( end )  ];
    y = [ -conf( 1 ) conf( 1 ) conf( 1 ) -conf( 1 ) ];
    patch( x, y, [ 0.9 0.9 0.9 ], 'EdgeColor', 'none' )
    hold on
    plot( f, dz );
    ylabel( 'Test statistic' );
    % line( get( gca, 'xlim' ), [ conf conf ],...
    %     'Color', [ 0.5 0.5 0.5 ], 'LineStyle', '--', 'LineWidth', 1 );
    % line( get( gca, 'xlim' ), [ -conf -conf ],...
    %     'Color', [ 0.5 0.5 0.5 ], 'LineStyle', '--', 'LineWidth', 1 );
    
    subplot( 3, 1, 3 );
    plot( f, vdz );
    xlabel( 'frequency' ); 
    ylabel( 'Jackknifed variance' );
    
end