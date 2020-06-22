from functools import wraps
import sys

class cclr:
    RED = '\033[91m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    MAGENTA = '\033[95m'
    CYAN = '\033[96m'
    WHITE = '\033[97m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'
    ERASE = '\033[2K'
    SBOXR = u'\u2514'
    SHR = u'\u2500'

class Logger:
    def __init__(self):
        self.depth = 0

    def stepIn(self):
        self.depth += 1

    def stepOut(self):
        self.depth -= 1

    def step(self, step, max_step, message, replace=False):
        self.__write(f"[{cclr.GREEN}{step}{cclr.ENDC}/{cclr.GREEN}{max_step}{cclr.ENDC}] {message}", replace)

    def info(self, message, replace=False):
        self.__write(f"[{cclr.BLUE}INFO{cclr.ENDC}] {message}", replace)

    def warn(self, message, replace=False):
        self.__write(f"[{cclr.YELLOW}WARN{cclr.ENDC}] {message}", replace)

    def error(self, message, replace=False):
        self.__write(f"[{cclr.RED}ERROR{cclr.ENDC}] {message}", replace)

    def __write(self, message, replace):
        if replace:
            sys.stdout.write(f'{cclr.ERASE}\r')
        else:
            sys.stdout.write('\n')
        if self.depth > 0:
            sys.stdout.write(f"{cclr.SBOXR}{cclr.SHR*((self.depth*2)-1)} ")
        sys.stdout.write(message)
        sys.stdout.flush()

def staged(log: Logger):
    def logStager(f):
        @wraps(f)
        def wrapper(*args, **kwds):
            log.stepIn()
            res = f(*args, **kwds)
            log.stepOut()
            return res
        return wrapper
    return logStager