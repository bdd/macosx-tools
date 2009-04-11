// Copyright (c) 2009 Berk D. Demir <bdd@mindcast.org>
// 
// Permission to use, copy, modify, and distribute this software for any
// purpose with or without fee is hereby granted, provided that the above
// copyright notice and this permission notice appear in all copies.
// 
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
// WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
// ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
// WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
// ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
// OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.


#import <Foundation/Foundation.h>
#include <err.h>
#include <stdio.h>
// Prototypes for IOBluetoothPrefecence* family of functions are not in SDK's
// header files. We will link against IOBluetooth.framework and suppress gcc's
// implict declaration errors.

// Type Definitions
typedef enum { CMD_NONE, CMD_ON, CMD_OFF, CMD_STATUS, CMD_TOGGLE } command_t;

// Prototypes
void err_exit_handler(int);

// Macros
#define GETPOWERSTATE()     IOBluetoothPreferenceGetControllerPowerState()
#define SETPOWERSTATE(x)    IOBluetoothPreferenceSetControllerPowerState(x)
#define STATUS_STRING       GETPOWERSTATE() ? "on" : "off"
#define USAGE_DOC           "usage: %s [on | off | status | toggle]\n"

// Globals
NSAutoreleasePool *AutoreleasePool = NULL;

void
err_exit_handler(int p __attribute__((unused)))
{
    [AutoreleasePool release];
}

int
main(int argc, const char *argv[])
{
    AutoreleasePool = [[NSAutoreleasePool alloc] init];
    NSString *nssArgv0 = [[NSString alloc] initWithCString:argv[0]];
    command_t command = CMD_NONE;
    int exitval = EXIT_SUCCESS;

    err_set_exit(err_exit_handler);

    if (!IOBluetoothPreferencesAvailable())
        errx(EXIT_FAILURE, "Bluetooth controller not found.");

    switch (argc) {
        case 1:
            if ([nssArgv0 hasSuffix:@"-on"])
                command = CMD_ON;
            else if ([nssArgv0 hasSuffix:@"-off"])
                command = CMD_OFF;
            else if ([nssArgv0 hasSuffix:@"-toggle"])
                command = CMD_TOGGLE;
            else if ([nssArgv0 hasSuffix:@"-status"])
                command = CMD_STATUS;
            break;

        case 2:
            if (strcmp(argv[1], "on") == 0)
                command = CMD_ON;
            else if (strcmp(argv[1], "off") == 0)
                command = CMD_OFF;
            else if (strcmp(argv[1], "toggle") == 0)
                command = CMD_TOGGLE;
            else if (strcmp(argv[1], "status") == 0)
                command = CMD_STATUS;
            break;
    }

    switch (command) {
        case CMD_ON:
            exitval = SETPOWERSTATE(1);
            break;
        case CMD_OFF:
            exitval = SETPOWERSTATE(0);
            break;
        case CMD_TOGGLE:
            exitval = SETPOWERSTATE((GETPOWERSTATE() + 1) % 2);
            break;
        case CMD_STATUS:
            fprintf(stdout, "%s\n", STATUS_STRING);
            break;
        default:
            fprintf(stderr, USAGE_DOC, argv[0]);
            exitval = EXIT_FAILURE;
    }

    [AutoreleasePool release];
    return exitval;
}
