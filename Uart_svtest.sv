class transaction;
  randc bit [7:0] datat;
  bit [7:0] datar;
  bit tx_done, parity_error,rx_complete;
  
  task display();
    $display("%0d----%0d---%0d",datat,datar, parity_error);
  endtask 
  
  function transaction copy();
    copy=new();
    copy.datat=datat;
    copy.datar=datar;
     copy.tx_done=tx_done;
     copy.parity_error=parity_error;
     copy.rx_complete=rx_complete;
  endfunction
    
endclass

interface pins;
  logic clk_3125,parity_type,tx_start, tx_done;
  logic [7:0] datat,datar,rx_msg;
  logic rx_complete,parity_error,rx_parity;
endinterface

class generator;
  transaction t;
  mailbox #(transaction) mbx;
  int i;
  function new(input mailbox #(transaction) mbx);
    this.mbx=mbx;
  endfunction 
  
  task run();
    t=new();
    for (i=0;i<10;i++)begin
      t.randomize();
      $display("-----GENARATOR------");
      t.display();
      mbx.put(t.copy());
      #40;
    end
  endtask
    
endclass
    
    
class driver;
  event a;
  transaction t;
  mailbox #(transaction) mbx;
  virtual pins dri;
  
  function new(input mailbox #(transaction) mbx);
    this.mbx=mbx;
  endfunction 
  
  task run();
    t=new();
    forever begin
      @(a);
      dri.tx_start=1'b0;
      mbx.get(t);
      dri.datat=t.datat;
      dri.parity_type=1'b0;
      dri.tx_start=1'b1;
     
      $display("-----DRIVER-----");
      t.display();
    end
  endtask
  
endclass

class monitor; 
  event a;
  virtual pins mon;
  transaction t;
  mailbox #(transaction) mbx1;
  
  function new(mailbox #(transaction) mbx1);
     this.mbx1=mbx1;
       t=new();
  endfunction 
  
  task run();
    ->a;
    forever begin 
      @(posedge mon.clk_3125);
      t.datat=mon.datat;
      t.datar=mon.datar;
      @(posedge mon.rx_complete);
     
      
      t.datar=mon.datar;
      t.tx_done=mon.tx_done;
      t.parity_error=mon. parity_error;
      t.rx_complete=mon.rx_complete;
      
      $display("MONITOR");
      t.display();
      ->a;
      mbx1.put(t.copy());
      
    end
  endtask 
  
endclass

class scoreboard;
  transaction t;
  mailbox #(transaction) mbx1;
  function new(mailbox #(transaction) mbx1);
     this.mbx1=mbx1;
  endfunction
  
  task run();
    t=new();
    forever begin 
      mbx1.get(t);
      $display("-----SCOREBOARD----");
      $display("tdata=%0d..rdata=%0d..error=%0d",t.datat,t.datar,t.parity_error);
    end
  endtask
endclass


module top;
  generator g;
  driver d;
  monitor m;
  scoreboard s;
  pins pin();
  mailbox #(transaction) mbx,mbx1;
  event a;
  wire serial_line;
  
  initial begin
    mbx=new();
    mbx1=new();
    g=new(mbx);
    d=new(mbx);
    m=new(mbx1);
    s=new(mbx1);
    d.dri=pin;
    m.mon=pin;
    d.a=a;
    m.a=a;
  end
  
initial  pin.clk_3125 = 0;

always #160 pin.clk_3125 = ~pin.clk_3125;
  
uart_tx TX (
  .clk_3125(pin.clk_3125),
  .parity_type(pin.parity_type),
  .tx_start(pin.tx_start),
  .data(pin.datat),
  .tx(serial_line),
  .tx_done(pin.tx_done)
);
  
uart_rx RX (
  .clk_3125(pin.clk_3125),
    .rx(serial_line),
  .rx_msg(pin.datar),
  .rx_parity(pin.rx_parity),
  .parity_error(pin.parity_error),
  .rx_complete(pin.rx_complete)
);
  initial begin 
    fork 
      g.run();
      d.run();
      m.run();
      s.run();
    join_any
    $dumpfile("waves.vcd");

$dumpvars(0,
  pin.clk_3125,
  pin.datat
);

    #2000000 $finish;
  end
endmodule
    
    
    
    
    
  
      
      
  
  
   
    
  
  
  
      
      
      
      
    
    
      
    
  
