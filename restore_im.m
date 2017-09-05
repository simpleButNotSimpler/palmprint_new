function [im_out, idx] = restore_im(orig_rotated_im, orig_db_im)
    %convert image to binary
    bw_im = orig_rotated_im > 0;
    
    %apply convexhull
    bw_im = bwconvhull(bw_im);
    witness = bw_im > 0;
    
    im_out = orig_db_im;
    im_out(witness) = orig_rotated_im(witness);
    
    [row, col] = find(~bw_im);
    idx = sub2ind([128, 128], row, col);
end