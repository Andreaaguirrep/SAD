FFS;

  C=Class[{},{},{f},
      g[f_]:={f}];

  c=C[];
  c@g[a]
  ?(c@g)
  ?(c@f)
end


