class transaction;
    rand bit mem_we;
    rand bit [10:0] mem_addr;
    rand bit [7:0] mem_write;
    bit mem_req;

    bit mem_done;
    bit [7:0] mem_read;


    constraint request{mem_req dist {1 := 4, 0 := 1};}
endclass
