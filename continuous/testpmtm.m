%Ttest matlab native addition to chronux
%% load some data
ccc

dataDrive = 'E:';
rootDir = 'Dropbox (Personal)\Projects\024_Anesthesia_PAC';
dataDir = 'Data\Midazolam\R12\2013-05-01';
fileName = 'R12_2013-05-01_Midazolam_AllChan.mat';

load( fullfile( dataDrive, rootDir, dataDir, fileName ) )

%% Compute the two spectrograms
clc
idx = strcmp( allChanPfc.Labels, 'CSC4' );
data = allChanPfc.Data( :, idx );
params = struct(...
    'tapers', [ 3 5 ],...
    'Fs', allChanPfc.Fs,...
    'fpass', [ 0.5 80 ],...
    'pad', 1,...
    'mttype', 'chronux' );
win = [ 4 0.4 ];

t1 = tic;
[ Schr, t, f ] = mtspecgramc( data, win, params );
tChr = toc( t1 );

params.mttype = 'native';
t1 = tic;
[ Snat, t, f ] = mtspecgramc( data, win, params );
tNat = toc( t1 );

fprintf( 'Chronux took %s s\n', humantime( tChr ) )
fprintf( 'Native took %s s\n', humantime( tNat ) )

figure
subplot( 2, 1, 1 )
imagesc( t, f, 10 * log10( Schr' ) )
axis xy
title( 'Chronux spectrogram')
ylabel( 'Frequency (Hz)')

subplot( 2, 1, 2 )
imagesc( t, f, 10 * log10( Snat' ) )
axis xy
title( 'Matlab pmtm spectrogram')
xlabel( 'time (s)')
ylabel( 'Frequency (Hz)')
