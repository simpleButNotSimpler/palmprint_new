function score = palmcode_diff_bw(im1, im2)
%take two palmcode as input and output the difference of their histogram

    siz1 = size(im1);
    siz2 = size(im2);
    if ~all(siz1 == siz2)
        disp('error: image size should be the same!')
        score = [];
        return
    end
    
    histo_vector1 = code_image_histo(im1);
    histo_vector2 = code_image_histo(im2);
    
    score = sum(abs(histo_vector1 - histo_vector2)) / sum(histo_vector1);
end

function histo_vector = code_image_histo(im)
   [limx, limy] = size(im);
   row = 1;
   histo_vector = [];
   bsize = 15;
   args = bsize+1;
   
   while (limx >= row+bsize)
       col = 1;
       while (limy >= col+bsize)
            block = im(row:row+bsize, col:col+bsize);
            histo_vector = [histo_vector, code_block_histo(block, args, args)];
            col = col+bsize+1;
       end
       
       row = row+bsize+1;
   end
end

function hv = code_block_histo(im, row, col)
   hv = zeros(1, 2);
   
   for t=1:row
       for k=1:col
           if ~im(t,k)
              hv(1) = hv(1) + 1; 
           else
              hv(2) = hv(2) + 1; 
           end
       end
   end
end