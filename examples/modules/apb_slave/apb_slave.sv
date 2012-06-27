//###############################################################
//
//  Licensed to the Apache Software Foundation (ASF) under one
//  or more contributor license agreements.  See the NOTICE file
//  distributed with this work for additional information
//  regarding copyright ownership.  The ASF licenses this file
//  to you under the Apache License, Version 2.0 (the
//  "License"); you may not use this file except in compliance
//  with the License.  You may obtain a copy of the License at
//  
//  http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the License is distributed on an
//  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
//  KIND, either express or implied.  See the License for the
//  specific language governing permissions and limitations
//  under the License.
//
//###############################################################

module apb_slave
#(
  addrWidth = 8,
  dataWidth = 32
)
(
  input                        clk,
  input                        rst_n,
  input        [addrWidth-1:0] paddr,
  input                        pwrite,
  input                        psel,
  input                        penable,
  input        [dataWidth-1:0] pwdata,
  output logic [dataWidth-1:0] prdata
);

logic [dataWidth-1:0] mem [256];

logic [1:0] apb_st;
const logic [1:0] SETUP = 0;
const logic [1:0] W_ENABLE = 1;
const logic [1:0] R_ENABLE = 2;

// SETUP -> ENABLE
always @(negedge rst_n or posedge clk) begin
  if (rst_n == 0) begin
    apb_st <= 0;
    prdata <= 0;
  end

  else begin
    case (apb_st)
      SETUP : begin
        // clear the prdata
        prdata <= 0;

        // Move to ENABLE when the psel is asserted
        if (psel && !penable) begin
          if (pwrite) begin
            apb_st <= W_ENABLE;
          end

          else begin
            apb_st <= R_ENABLE;
          end
        end
      end

      W_ENABLE : begin
        // write pwdata to memory
        if (psel && penable && pwrite) begin
          mem[paddr] <= pwdata;
        end

        // return to SETUP
        apb_st <= SETUP;
      end

      R_ENABLE : begin
        // read prdata from memory
        if (psel && penable && !pwrite) begin
          prdata <= mem[paddr];
        end

        // return to SETUP
        apb_st <= SETUP;
      end
    endcase
  end
end 


endmodule
