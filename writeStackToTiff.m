function writeStackToTiff(vol, fname)
% Save a 3D array as a multi-page TIFF with correct bit depth tags

    % Decide depth
    if isa(vol,'uint8')
        bits = 8;  sampleFmt = Tiff.SampleFormat.UInt;   bytesPerPix = 1;
    elseif isa(vol,'uint16')
        bits = 16; sampleFmt = Tiff.SampleFormat.UInt;   bytesPerPix = 2;
    else
        % convert other types to 16-bit
        vol = uint16(65535 * mat2gray(vol));
        bits = 16; sampleFmt = Tiff.SampleFormat.UInt;   bytesPerPix = 2;
    end

    % BigTIFF if needed
    estBytes = numel(vol) * bytesPerPix;
    mode = 'w';
    if estBytes >= 4e9, mode = 'w8'; end

    tag.ImageLength         = size(vol,1);
    tag.ImageWidth          = size(vol,2);
    tag.Photometric         = Tiff.Photometric.MinIsBlack;
    tag.BitsPerSample       = bits;                      % <-- correct!
    tag.SamplesPerPixel     = 1;
    tag.RowsPerStrip        = size(vol,1);
    tag.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    tag.Compression         = Tiff.Compression.None;     % avoid IJ compressed path
    tag.SampleFormat        = sampleFmt;
    tag.Software            = 'MATLAB';

    t = Tiff(fname, mode);
    c = onCleanup(@() t.close());
    for k = 1:size(vol,3)
        t.setTag(tag);
        t.write(vol(:,:,k));
        if k < size(vol,3), t.writeDirectory(); end
    end
end
