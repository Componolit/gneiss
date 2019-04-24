
#include <entrypoint.h>
#include <stdio.h>
#include <block_client.h>

void entry_sigusr1(siginfo_t *info)
{ }

void entry_sigio(siginfo_t *info)
{
    if(info->si_signo == 29 && info->si_code == -4 && info->si_value.sival_ptr){
        ((block_client_t *)(info->si_value.sival_ptr))->event();
    }
}
