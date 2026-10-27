// The line a x + b y + c = 0. CGELineUndefined (all zero) is no line.
struct CGELine {
    CGFloat a;
    CGFloat b;
    CGFloat c;
};
typedef struct CGELine CGELine;

extern const CGELine CGELineUndefined;
