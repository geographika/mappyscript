

extern int yyparse(parseObj *);


  expressionObj e;
  parseObj p;

  /* initialize a temporary expression (e) */
  msInitExpression(&e);

  e.string = msStrdup(context);
  e.type = MS_EXPRESSION; /* todo */

      int status;
      parseObj p;

      p.shape = shape;
      p.expr = expression;
      p.expr->curtoken = p.expr->tokens; /* reset */
      p.type = MS_PARSE_TYPE_BOOLEAN;

      status = yyparse(&p);

      if (status != 0) {
        msSetError(MS_PARSEERR, "Failed to parse expression: %s", "msEvalExpression", expression->string);
        return MS_FALSE;
      }

      return p.result.intval;




/* msEvalExpression()
 *
 * Evaluates a mapserver expression for a given set of attribute values and
 * returns the result of the expression (MS_TRUE or MS_FALSE)
 * May also return MS_FALSE in case of parsing errors or invalid expressions
 * (check the error stack if you care)
 *
 */
int msEvalExpression(layerObj *layer, shapeObj *shape, expressionObj *expression, int itemindex)