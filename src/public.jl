for fname in TG_PREDICATES
    eval(Expr(:public, fname))
end