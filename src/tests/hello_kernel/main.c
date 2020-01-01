
#include <linux/module.h>
#include <linux/kernel.h>

#include "tests/hello_kernel/utils/utils.h"

int init_module(void)    
{
    printk(KERN_INFO "Hello kernel.\n");
    say_hello();

    /* 
     * A non 0 return means init_module failed; module can't be loaded. 
     */
    return 0;
}

void cleanup_module(void)
{
    printk(KERN_INFO "Goodbye kernel.\n");
    say_goodbay();
}
