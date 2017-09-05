function score = palmcode_diff_whole(im1, im2)
%take two palmcode as input and output the difference of their histogram

    siz1 = size(im1);
    siz2 = size(im2);
    if ~all(siz1 == siz2)
        disp('error: image size should be the same!')
        score = [];
        return
    end
    
    bsize = floor(siz1(1)/4);
    blocks = 1:bsize:siz1(1)+1;
    blocks(end) = siz1(1)+1;
    
    histo_vector1 = code_image_histo(im1, blocks);
    histo_vector2 = code_image_histo(im2, blocks);
    
    score = sum(abs(histo_vector1 - histo_vector2)) / (siz1(1)*siz1(2));
end

function histo_vector = code_image_histo(im, range)
   histo_vector = [];   
   len = numel(range) - 1;
   
   for m=1:len
       for n=1:len
           block = im(range(m):range(m+1)-1, range(n):range(n+1)-1);
           histo_vector = [histo_vector, code_block_histo(block)];
       end       
   end
end

function hv = code_block_histo(im)
   hv = zeros(1, 9);
   [row, col] = size(im);
   
   for t=1:row
       for k=1:col
           idx = (im(t,k)/20) + 1;
           hv(idx) =  hv(idx) + 1;
       end
   end
end