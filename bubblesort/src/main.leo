program bubblesort.aleo {
    transition bubble_sort(xs: [u32; 8]) -> [u32; 8] {
        for i: u8 in 0u8..7u8 {
            for j: u8 in 0u8..7u8-i {
                // Move the smaller elements forward
                if xs[j+1u8] < xs[j] {
                    let swap: u32 = xs[j];
                    // let swap = xs[j];
                    xs[j] = xs[j+1u8];
                    xs[j+1u8] = swap;
                }
            }
        }
        return xs;
    }
}
