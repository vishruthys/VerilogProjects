#include <stdlib.h>
#include "pipeline.h"
#include "verilated.h"
#include <verilated_vcd_c.h>

struct TestCase{
    uint8_t ra1;
    uint8_t ra2;
    uint8_t func;
    uint8_t rwa;
    uint8_t ma;
    // uint8_t C;//output
};


class TestBench
{
    unsigned long tickcount;
    pipeline *p4stage;
    VerilatedVcdC *trace;

public:    TestBench(void)
    {
        Verilated::traceEverOn(true);
        p4stage = new pipeline;
        tickcount = 0l;
        p4stage->clk1 = 0;
        p4stage->clk2 = 0;
        for(int i=0;i<16;i++)
        {
            p4stage->pipeline__DOT__regbank[i] = i*i;
        }
/*         p4stage->ra1 = 2;
        p4stage->ra2 = 7;
        p4stage->func = 0;
        p4stage->rwa = 12;
        p4stage->ma = 145; */
    }

    ~TestBench(void){
        delete p4stage;
        p4stage = NULL;

        delete trace;
        trace = NULL;
    }

    //reset not present in design
    void opentrace(const char *vcdname) {
		if (!trace) {
			trace = new VerilatedVcdC;
			p4stage->trace(trace, 99);
			trace->open(vcdname);
		}
	}

    void close(void) {
		if (trace) {
			trace->close();
			trace = NULL;
		}
	}

    void loadInputs(TestCase *tc)
    {
        p4stage->ra1 = tc->ra1;
        p4stage->ra2 = tc->ra2;
        p4stage->func = tc->func;
        p4stage->rwa = tc->rwa;
        p4stage->ma = tc->ma;
    }

    void tick(void)
    {
        tickcount++;

        p4stage->eval();
        if(trace) trace->dump(10*tickcount-2);

        p4stage->clk2 = 0;
        p4stage->eval();
        if(trace) trace->dump(10*tickcount);

        p4stage->clk1 = 1;
        p4stage->eval();
        if(trace) trace->dump(10*tickcount+1);

        p4stage->clk1 = 0;
        p4stage->eval();
        if(trace) trace->dump(10*tickcount+5);
        p4stage->clk2 = 1;
        p4stage->eval();
        if(trace) trace->dump(10*tickcount+6);

        if (trace) {
            trace->dump(10*tickcount+7);
            trace->flush();
        }
    }

    bool done(void)
    {
        return (Verilated::gotFinish());
    }
};

TestCase tc[]={
    {2,7,0,12,145},
    {1,4,4,13,169},
    {9,5,3,11,132},
    {6,2,7,14,140},
};

int main(int argc, char **argv) {
	Verilated::commandArgs(argc, argv);
	TestBench *tb = new TestBench();
    tb->opentrace("trace.vcd");
    int n = sizeof(tc)/sizeof(TestCase);

    for(int i=0; i<n; i++)
    {
        tb->loadInputs(&tc[i]);
        tb->tick();
    }
    tb->tick();
    exit(0);
    /* 
    tb->loadInputs(&tc[1]);
    tb->tick();
    tb->loadInputs(&tc[2]);
    tb->tick();
    tb->loadInputs(&tc[3]);
    tb->tick();
	while(!tb->done()) {
		tb->tick();
	} exit(EXIT_SUCCESS); */

}