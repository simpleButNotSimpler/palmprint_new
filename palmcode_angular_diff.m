function score = palmcode_angular_diff(im1, im2)
%take two palmcode as input and output the difference of their histogram
        
    siz1 = size(im1);
    siz2 = size(im2);
    if ~all(siz1 == siz2)
        disp('error: image size should be the same!')
        score = [];
        return
    end
    
    score = 0.0;
    
    
    % preprocessing
    bw_im = im1 > 0; %convert image to binary
    bw_im = bwconvhull(bw_im); %apply convexhull
    
    [row, col] = find(bw_im);
    idx = sub2ind(siz1, row, col);
    
    %simplify
    im1 = double(im1/20);
    im2 = double(im2/20);
    
    for t=1:numel(idx)
        index = idx(t);
        score = score + angular(im1(index), im2(index));
    end
    
    fac = 4*numel(idx);
    score = score / fac;
end

function min_dif = angular(p, q)
    if p >= q
        min_dif = min([p-q, q-p+9]);
    else
        min_dif = min([q-p, p-q+9]);
    end    
end