#include <linux/kernel.h>

void say_hello(void)
{
    printk(KERN_INFO "Saying Hello.\n");
}

void say_goodbay(void)
{
    printk(KERN_INFO "Saying Goodbay.\n");
}
