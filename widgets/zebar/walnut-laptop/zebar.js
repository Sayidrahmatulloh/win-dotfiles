var x;
(function (t) {
  t.assertEqual = (s) => s;
  function e(s) {}
  t.assertIs = e;
  function r(s) {
    throw new Error();
  }
  ((t.assertNever = r),
    (t.arrayToEnum = (s) => {
      let i = {};
      for (let a of s) i[a] = a;
      return i;
    }),
    (t.getValidEnumValues = (s) => {
      let i = t.objectKeys(s).filter((o) => typeof s[s[o]] != "number"),
        a = {};
      for (let o of i) a[o] = s[o];
      return t.objectValues(a);
    }),
    (t.objectValues = (s) =>
      t.objectKeys(s).map(function (i) {
        return s[i];
      })),
    (t.objectKeys =
      typeof Object.keys == "function"
        ? (s) => Object.keys(s)
        : (s) => {
            let i = [];
            for (let a in s) Object.prototype.hasOwnProperty.call(s, a) && i.push(a);
            return i;
          }),
    (t.find = (s, i) => {
      for (let a of s) if (i(a)) return a;
    }),
    (t.isInteger =
      typeof Number.isInteger == "function"
        ? (s) => Number.isInteger(s)
        : (s) => typeof s == "number" && isFinite(s) && Math.floor(s) === s));
  function n(s, i = " | ") {
    return s.map((a) => (typeof a == "string" ? `'${a}'` : a)).join(i);
  }
  ((t.joinValues = n),
    (t.jsonStringifyReplacer = (s, i) => (typeof i == "bigint" ? i.toString() : i)));
})(x || (x = {}));
var Or;
(function (t) {
  t.mergeShapes = (e, r) => ({ ...e, ...r });
})(Or || (Or = {}));
var p = x.arrayToEnum([
    "string",
    "nan",
    "number",
    "integer",
    "float",
    "boolean",
    "date",
    "bigint",
    "symbol",
    "function",
    "undefined",
    "null",
    "array",
    "object",
    "unknown",
    "promise",
    "void",
    "never",
    "map",
    "set",
  ]),
  ue = (t) => {
    switch (typeof t) {
      case "undefined":
        return p.undefined;
      case "string":
        return p.string;
      case "number":
        return isNaN(t) ? p.nan : p.number;
      case "boolean":
        return p.boolean;
      case "function":
        return p.function;
      case "bigint":
        return p.bigint;
      case "symbol":
        return p.symbol;
      case "object":
        return Array.isArray(t)
          ? p.array
          : t === null
            ? p.null
            : t.then && typeof t.then == "function" && t.catch && typeof t.catch == "function"
              ? p.promise
              : typeof Map < "u" && t instanceof Map
                ? p.map
                : typeof Set < "u" && t instanceof Set
                  ? p.set
                  : typeof Date < "u" && t instanceof Date
                    ? p.date
                    : p.object;
      default:
        return p.unknown;
    }
  },
  f = x.arrayToEnum([
    "invalid_type",
    "invalid_literal",
    "custom",
    "invalid_union",
    "invalid_union_discriminator",
    "invalid_enum_value",
    "unrecognized_keys",
    "invalid_arguments",
    "invalid_return_type",
    "invalid_date",
    "invalid_string",
    "too_small",
    "too_big",
    "invalid_intersection_types",
    "not_multiple_of",
    "not_finite",
  ]),
  Xs = (t) => JSON.stringify(t, null, 2).replace(/"([^"]+)":/g, "$1:"),
  $ = class t extends Error {
    get errors() {
      return this.issues;
    }
    constructor(e) {
      (super(),
        (this.issues = []),
        (this.addIssue = (n) => {
          this.issues = [...this.issues, n];
        }),
        (this.addIssues = (n = []) => {
          this.issues = [...this.issues, ...n];
        }));
      let r = new.target.prototype;
      (Object.setPrototypeOf ? Object.setPrototypeOf(this, r) : (this.__proto__ = r),
        (this.name = "ZodError"),
        (this.issues = e));
    }
    format(e) {
      let r =
          e ||
          function (i) {
            return i.message;
          },
        n = { _errors: [] },
        s = (i) => {
          for (let a of i.issues)
            if (a.code === "invalid_union") a.unionErrors.map(s);
            else if (a.code === "invalid_return_type") s(a.returnTypeError);
            else if (a.code === "invalid_arguments") s(a.argumentsError);
            else if (a.path.length === 0) n._errors.push(r(a));
            else {
              let o = n,
                l = 0;
              for (; l < a.path.length; ) {
                let u = a.path[l];
                (l === a.path.length - 1
                  ? ((o[u] = o[u] || { _errors: [] }), o[u]._errors.push(r(a)))
                  : (o[u] = o[u] || { _errors: [] }),
                  (o = o[u]),
                  l++);
              }
            }
        };
      return (s(this), n);
    }
    static assert(e) {
      if (!(e instanceof t)) throw new Error(`Not a ZodError: ${e}`);
    }
    toString() {
      return this.message;
    }
    get message() {
      return JSON.stringify(this.issues, x.jsonStringifyReplacer, 2);
    }
    get isEmpty() {
      return this.issues.length === 0;
    }
    flatten(e = (r) => r.message) {
      let r = {},
        n = [];
      for (let s of this.issues)
        s.path.length > 0
          ? ((r[s.path[0]] = r[s.path[0]] || []), r[s.path[0]].push(e(s)))
          : n.push(e(s));
      return { formErrors: n, fieldErrors: r };
    }
    get formErrors() {
      return this.flatten();
    }
  };
$.create = (t) => new $(t);
var Ke = (t, e) => {
    let r;
    switch (t.code) {
      case f.invalid_type:
        t.received === p.undefined
          ? (r = "Required")
          : (r = `Expected ${t.expected}, received ${t.received}`);
        break;
      case f.invalid_literal:
        r = `Invalid literal value, expected ${JSON.stringify(t.expected, x.jsonStringifyReplacer)}`;
        break;
      case f.unrecognized_keys:
        r = `Unrecognized key(s) in object: ${x.joinValues(t.keys, ", ")}`;
        break;
      case f.invalid_union:
        r = "Invalid input";
        break;
      case f.invalid_union_discriminator:
        r = `Invalid discriminator value. Expected ${x.joinValues(t.options)}`;
        break;
      case f.invalid_enum_value:
        r = `Invalid enum value. Expected ${x.joinValues(t.options)}, received '${t.received}'`;
        break;
      case f.invalid_arguments:
        r = "Invalid function arguments";
        break;
      case f.invalid_return_type:
        r = "Invalid function return type";
        break;
      case f.invalid_date:
        r = "Invalid date";
        break;
      case f.invalid_string:
        typeof t.validation == "object"
          ? "includes" in t.validation
            ? ((r = `Invalid input: must include "${t.validation.includes}"`),
              typeof t.validation.position == "number" &&
                (r = `${r} at one or more positions greater than or equal to ${t.validation.position}`))
            : "startsWith" in t.validation
              ? (r = `Invalid input: must start with "${t.validation.startsWith}"`)
              : "endsWith" in t.validation
                ? (r = `Invalid input: must end with "${t.validation.endsWith}"`)
                : x.assertNever(t.validation)
          : t.validation !== "regex"
            ? (r = `Invalid ${t.validation}`)
            : (r = "Invalid");
        break;
      case f.too_small:
        t.type === "array"
          ? (r = `Array must contain ${t.exact ? "exactly" : t.inclusive ? "at least" : "more than"} ${t.minimum} element(s)`)
          : t.type === "string"
            ? (r = `String must contain ${t.exact ? "exactly" : t.inclusive ? "at least" : "over"} ${t.minimum} character(s)`)
            : t.type === "number"
              ? (r = `Number must be ${t.exact ? "exactly equal to " : t.inclusive ? "greater than or equal to " : "greater than "}${t.minimum}`)
              : t.type === "date"
                ? (r = `Date must be ${t.exact ? "exactly equal to " : t.inclusive ? "greater than or equal to " : "greater than "}${new Date(Number(t.minimum))}`)
                : (r = "Invalid input");
        break;
      case f.too_big:
        t.type === "array"
          ? (r = `Array must contain ${t.exact ? "exactly" : t.inclusive ? "at most" : "less than"} ${t.maximum} element(s)`)
          : t.type === "string"
            ? (r = `String must contain ${t.exact ? "exactly" : t.inclusive ? "at most" : "under"} ${t.maximum} character(s)`)
            : t.type === "number"
              ? (r = `Number must be ${t.exact ? "exactly" : t.inclusive ? "less than or equal to" : "less than"} ${t.maximum}`)
              : t.type === "bigint"
                ? (r = `BigInt must be ${t.exact ? "exactly" : t.inclusive ? "less than or equal to" : "less than"} ${t.maximum}`)
                : t.type === "date"
                  ? (r = `Date must be ${t.exact ? "exactly" : t.inclusive ? "smaller than or equal to" : "smaller than"} ${new Date(Number(t.maximum))}`)
                  : (r = "Invalid input");
        break;
      case f.custom:
        r = "Invalid input";
        break;
      case f.invalid_intersection_types:
        r = "Intersection results could not be merged";
        break;
      case f.not_multiple_of:
        r = `Number must be a multiple of ${t.multipleOf}`;
        break;
      case f.not_finite:
        r = "Number must be finite";
        break;
      default:
        ((r = e.defaultError), x.assertNever(t));
    }
    return { message: r };
  },
  kn = Ke;
function ei(t) {
  kn = t;
}
function er() {
  return kn;
}
var tr = (t) => {
    let { data: e, path: r, errorMaps: n, issueData: s } = t,
      i = [...r, ...(s.path || [])],
      a = { ...s, path: i };
    if (s.message !== void 0) return { ...s, path: i, message: s.message };
    let o = "",
      l = n
        .filter((u) => !!u)
        .slice()
        .reverse();
    for (let u of l) o = u(a, { data: e, defaultError: o }).message;
    return { ...s, path: i, message: o };
  },
  ti = [];
function h(t, e) {
  let r = er(),
    n = tr({
      issueData: e,
      data: t.data,
      path: t.path,
      errorMaps: [t.common.contextualErrorMap, t.schemaErrorMap, r, r === Ke ? void 0 : Ke].filter(
        (s) => !!s,
      ),
    });
  t.common.issues.push(n);
}
var R = class t {
    constructor() {
      this.value = "valid";
    }
    dirty() {
      this.value === "valid" && (this.value = "dirty");
    }
    abort() {
      this.value !== "aborted" && (this.value = "aborted");
    }
    static mergeArray(e, r) {
      let n = [];
      for (let s of r) {
        if (s.status === "aborted") return T;
        (s.status === "dirty" && e.dirty(), n.push(s.value));
      }
      return { status: e.value, value: n };
    }
    static async mergeObjectAsync(e, r) {
      let n = [];
      for (let s of r) {
        let i = await s.key,
          a = await s.value;
        n.push({ key: i, value: a });
      }
      return t.mergeObjectSync(e, n);
    }
    static mergeObjectSync(e, r) {
      let n = {};
      for (let s of r) {
        let { key: i, value: a } = s;
        if (i.status === "aborted" || a.status === "aborted") return T;
        (i.status === "dirty" && e.dirty(),
          a.status === "dirty" && e.dirty(),
          i.value !== "__proto__" &&
            (typeof a.value < "u" || s.alwaysSet) &&
            (n[i.value] = a.value));
      }
      return { status: e.value, value: n };
    }
  },
  T = Object.freeze({ status: "aborted" }),
  Je = (t) => ({ status: "dirty", value: t }),
  P = (t) => ({ status: "valid", value: t }),
  Ir = (t) => t.status === "aborted",
  Dr = (t) => t.status === "dirty",
  Ee = (t) => t.status === "valid",
  Tt = (t) => typeof Promise < "u" && t instanceof Promise;
function rr(t, e, r, n) {
  if (r === "a" && !n) throw new TypeError("Private accessor was defined without a getter");
  if (typeof e == "function" ? t !== e || !n : !e.has(t))
    throw new TypeError("Cannot read private member from an object whose class did not declare it");
  return r === "m" ? n : r === "a" ? n.call(t) : n ? n.value : e.get(t);
}
function xn(t, e, r, n, s) {
  if (n === "m") throw new TypeError("Private method is not writable");
  if (n === "a" && !s) throw new TypeError("Private accessor was defined without a setter");
  if (typeof e == "function" ? t !== e || !s : !e.has(t))
    throw new TypeError("Cannot write private member to an object whose class did not declare it");
  return (n === "a" ? s.call(t, r) : s ? (s.value = r) : e.set(t, r), r);
}
var y;
(function (t) {
  ((t.errToObj = (e) => (typeof e == "string" ? { message: e } : e || {})),
    (t.toString = (e) => (typeof e == "string" ? e : e?.message)));
})(y || (y = {}));
var wt,
  _t,
  Y = class {
    constructor(e, r, n, s) {
      ((this._cachedPath = []),
        (this.parent = e),
        (this.data = r),
        (this._path = n),
        (this._key = s));
    }
    get path() {
      return (
        this._cachedPath.length ||
          (this._key instanceof Array
            ? this._cachedPath.push(...this._path, ...this._key)
            : this._cachedPath.push(...this._path, this._key)),
        this._cachedPath
      );
    }
  },
  _n = (t, e) => {
    if (Ee(e)) return { success: !0, data: e.value };
    if (!t.common.issues.length) throw new Error("Validation failed but no issues detected.");
    return {
      success: !1,
      get error() {
        if (this._error) return this._error;
        let r = new $(t.common.issues);
        return ((this._error = r), this._error);
      },
    };
  };
function b(t) {
  if (!t) return {};
  let { errorMap: e, invalid_type_error: r, required_error: n, description: s } = t;
  if (e && (r || n))
    throw new Error(
      `Can't use "invalid_type_error" or "required_error" in conjunction with custom error map.`,
    );
  return e
    ? { errorMap: e, description: s }
    : {
        errorMap: (a, o) => {
          var l, u;
          let { message: d } = t;
          return a.code === "invalid_enum_value"
            ? { message: d ?? o.defaultError }
            : typeof o.data > "u"
              ? { message: (l = d ?? n) !== null && l !== void 0 ? l : o.defaultError }
              : a.code !== "invalid_type"
                ? { message: o.defaultError }
                : { message: (u = d ?? r) !== null && u !== void 0 ? u : o.defaultError };
        },
        description: s,
      };
}
var k = class {
    get description() {
      return this._def.description;
    }
    _getType(e) {
      return ue(e.data);
    }
    _getOrReturnCtx(e, r) {
      return (
        r || {
          common: e.parent.common,
          data: e.data,
          parsedType: ue(e.data),
          schemaErrorMap: this._def.errorMap,
          path: e.path,
          parent: e.parent,
        }
      );
    }
    _processInputParams(e) {
      return {
        status: new R(),
        ctx: {
          common: e.parent.common,
          data: e.data,
          parsedType: ue(e.data),
          schemaErrorMap: this._def.errorMap,
          path: e.path,
          parent: e.parent,
        },
      };
    }
    _parseSync(e) {
      let r = this._parse(e);
      if (Tt(r)) throw new Error("Synchronous parse encountered promise.");
      return r;
    }
    _parseAsync(e) {
      let r = this._parse(e);
      return Promise.resolve(r);
    }
    parse(e, r) {
      let n = this.safeParse(e, r);
      if (n.success) return n.data;
      throw n.error;
    }
    safeParse(e, r) {
      var n;
      let s = {
          common: {
            issues: [],
            async: (n = r?.async) !== null && n !== void 0 ? n : !1,
            contextualErrorMap: r?.errorMap,
          },
          path: r?.path || [],
          schemaErrorMap: this._def.errorMap,
          parent: null,
          data: e,
          parsedType: ue(e),
        },
        i = this._parseSync({ data: e, path: s.path, parent: s });
      return _n(s, i);
    }
    "~validate"(e) {
      var r, n;
      let s = {
        common: { issues: [], async: !!this["~standard"].async },
        path: [],
        schemaErrorMap: this._def.errorMap,
        parent: null,
        data: e,
        parsedType: ue(e),
      };
      if (!this["~standard"].async)
        try {
          let i = this._parseSync({ data: e, path: [], parent: s });
          return Ee(i) ? { value: i.value } : { issues: s.common.issues };
        } catch (i) {
          (!(
            (n = (r = i?.message) === null || r === void 0 ? void 0 : r.toLowerCase()) === null ||
            n === void 0
          ) &&
            n.includes("encountered") &&
            (this["~standard"].async = !0),
            (s.common = { issues: [], async: !0 }));
        }
      return this._parseAsync({ data: e, path: [], parent: s }).then((i) =>
        Ee(i) ? { value: i.value } : { issues: s.common.issues },
      );
    }
    async parseAsync(e, r) {
      let n = await this.safeParseAsync(e, r);
      if (n.success) return n.data;
      throw n.error;
    }
    async safeParseAsync(e, r) {
      let n = {
          common: { issues: [], contextualErrorMap: r?.errorMap, async: !0 },
          path: r?.path || [],
          schemaErrorMap: this._def.errorMap,
          parent: null,
          data: e,
          parsedType: ue(e),
        },
        s = this._parse({ data: e, path: n.path, parent: n }),
        i = await (Tt(s) ? s : Promise.resolve(s));
      return _n(n, i);
    }
    refine(e, r) {
      let n = (s) =>
        typeof r == "string" || typeof r > "u" ? { message: r } : typeof r == "function" ? r(s) : r;
      return this._refinement((s, i) => {
        let a = e(s),
          o = () => i.addIssue({ code: f.custom, ...n(s) });
        return typeof Promise < "u" && a instanceof Promise
          ? a.then((l) => (l ? !0 : (o(), !1)))
          : a
            ? !0
            : (o(), !1);
      });
    }
    refinement(e, r) {
      return this._refinement((n, s) =>
        e(n) ? !0 : (s.addIssue(typeof r == "function" ? r(n, s) : r), !1),
      );
    }
    _refinement(e) {
      return new j({
        schema: this,
        typeName: _.ZodEffects,
        effect: { type: "refinement", refinement: e },
      });
    }
    superRefine(e) {
      return this._refinement(e);
    }
    constructor(e) {
      ((this.spa = this.safeParseAsync),
        (this._def = e),
        (this.parse = this.parse.bind(this)),
        (this.safeParse = this.safeParse.bind(this)),
        (this.parseAsync = this.parseAsync.bind(this)),
        (this.safeParseAsync = this.safeParseAsync.bind(this)),
        (this.spa = this.spa.bind(this)),
        (this.refine = this.refine.bind(this)),
        (this.refinement = this.refinement.bind(this)),
        (this.superRefine = this.superRefine.bind(this)),
        (this.optional = this.optional.bind(this)),
        (this.nullable = this.nullable.bind(this)),
        (this.nullish = this.nullish.bind(this)),
        (this.array = this.array.bind(this)),
        (this.promise = this.promise.bind(this)),
        (this.or = this.or.bind(this)),
        (this.and = this.and.bind(this)),
        (this.transform = this.transform.bind(this)),
        (this.brand = this.brand.bind(this)),
        (this.default = this.default.bind(this)),
        (this.catch = this.catch.bind(this)),
        (this.describe = this.describe.bind(this)),
        (this.pipe = this.pipe.bind(this)),
        (this.readonly = this.readonly.bind(this)),
        (this.isNullable = this.isNullable.bind(this)),
        (this.isOptional = this.isOptional.bind(this)),
        (this["~standard"] = { version: 1, vendor: "zod", validate: (r) => this["~validate"](r) }));
    }
    optional() {
      return G.create(this, this._def);
    }
    nullable() {
      return ae.create(this, this._def);
    }
    nullish() {
      return this.nullable().optional();
    }
    array() {
      return de.create(this);
    }
    promise() {
      return ve.create(this, this._def);
    }
    or(e) {
      return Ae.create([this, e], this._def);
    }
    and(e) {
      return Fe.create(this, e, this._def);
    }
    transform(e) {
      return new j({
        ...b(this._def),
        schema: this,
        typeName: _.ZodEffects,
        effect: { type: "transform", transform: e },
      });
    }
    default(e) {
      let r = typeof e == "function" ? e : () => e;
      return new Pe({ ...b(this._def), innerType: this, defaultValue: r, typeName: _.ZodDefault });
    }
    brand() {
      return new bt({ typeName: _.ZodBranded, type: this, ...b(this._def) });
    }
    catch(e) {
      let r = typeof e == "function" ? e : () => e;
      return new ze({ ...b(this._def), innerType: this, catchValue: r, typeName: _.ZodCatch });
    }
    describe(e) {
      let r = this.constructor;
      return new r({ ...this._def, description: e });
    }
    pipe(e) {
      return kt.create(this, e);
    }
    readonly() {
      return Ve.create(this);
    }
    isOptional() {
      return this.safeParse(void 0).success;
    }
    isNullable() {
      return this.safeParse(null).success;
    }
  },
  ri = /^c[^\s-]{8,}$/i,
  ni = /^[0-9a-z]+$/,
  si = /^[0-9A-HJKMNP-TV-Z]{26}$/i,
  ii = /^[0-9a-fA-F]{8}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{12}$/i,
  ai = /^[a-z0-9_-]{21}$/i,
  oi = /^[A-Za-z0-9-_]+\.[A-Za-z0-9-_]+\.[A-Za-z0-9-_]*$/,
  li =
    /^[-+]?P(?!$)(?:(?:[-+]?\d+Y)|(?:[-+]?\d+[.,]\d+Y$))?(?:(?:[-+]?\d+M)|(?:[-+]?\d+[.,]\d+M$))?(?:(?:[-+]?\d+W)|(?:[-+]?\d+[.,]\d+W$))?(?:(?:[-+]?\d+D)|(?:[-+]?\d+[.,]\d+D$))?(?:T(?=[\d+-])(?:(?:[-+]?\d+H)|(?:[-+]?\d+[.,]\d+H$))?(?:(?:[-+]?\d+M)|(?:[-+]?\d+[.,]\d+M$))?(?:[-+]?\d+(?:[.,]\d+)?S)?)??$/,
  ui = /^(?!\.)(?!.*\.\.)([A-Z0-9_'+\-\.]*)[A-Z0-9_+-]@([A-Z0-9][A-Z0-9\-]*\.)+[A-Z]{2,}$/i,
  ci = "^(\\p{Extended_Pictographic}|\\p{Emoji_Component})+$",
  Er,
  di =
    /^(?:(?:25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])\.){3}(?:25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])$/,
  fi =
    /^(?:(?:25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])\.){3}(?:25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])\/(3[0-2]|[12]?[0-9])$/,
  hi =
    /^(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))$/,
  mi =
    /^(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))\/(12[0-8]|1[01][0-9]|[1-9]?[0-9])$/,
  pi = /^([0-9a-zA-Z+/]{4})*(([0-9a-zA-Z+/]{2}==)|([0-9a-zA-Z+/]{3}=))?$/,
  yi = /^([0-9a-zA-Z-_]{4})*(([0-9a-zA-Z-_]{2}(==)?)|([0-9a-zA-Z-_]{3}(=)?))?$/,
  Sn =
    "((\\d\\d[2468][048]|\\d\\d[13579][26]|\\d\\d0[48]|[02468][048]00|[13579][26]00)-02-29|\\d{4}-((0[13578]|1[02])-(0[1-9]|[12]\\d|3[01])|(0[469]|11)-(0[1-9]|[12]\\d|30)|(02)-(0[1-9]|1\\d|2[0-8])))",
  gi = new RegExp(`^${Sn}$`);
function En(t) {
  let e = "([01]\\d|2[0-3]):[0-5]\\d:[0-5]\\d";
  return (
    t.precision
      ? (e = `${e}\\.\\d{${t.precision}}`)
      : t.precision == null && (e = `${e}(\\.\\d+)?`),
    e
  );
}
function vi(t) {
  return new RegExp(`^${En(t)}$`);
}
function On(t) {
  let e = `${Sn}T${En(t)}`,
    r = [];
  return (
    r.push(t.local ? "Z?" : "Z"),
    t.offset && r.push("([+-]\\d{2}:?\\d{2})"),
    (e = `${e}(${r.join("|")})`),
    new RegExp(`^${e}$`)
  );
}
function wi(t, e) {
  return !!(((e === "v4" || !e) && di.test(t)) || ((e === "v6" || !e) && hi.test(t)));
}
function _i(t, e) {
  if (!oi.test(t)) return !1;
  try {
    let [r] = t.split("."),
      n = r
        .replace(/-/g, "+")
        .replace(/_/g, "/")
        .padEnd(r.length + ((4 - (r.length % 4)) % 4), "="),
      s = JSON.parse(atob(n));
    return !(typeof s != "object" || s === null || !s.typ || !s.alg || (e && s.alg !== e));
  } catch {
    return !1;
  }
}
function Ti(t, e) {
  return !!(((e === "v4" || !e) && fi.test(t)) || ((e === "v6" || !e) && mi.test(t)));
}
var ye = class t extends k {
  _parse(e) {
    if ((this._def.coerce && (e.data = String(e.data)), this._getType(e) !== p.string)) {
      let i = this._getOrReturnCtx(e);
      return (h(i, { code: f.invalid_type, expected: p.string, received: i.parsedType }), T);
    }
    let n = new R(),
      s;
    for (let i of this._def.checks)
      if (i.kind === "min")
        e.data.length < i.value &&
          ((s = this._getOrReturnCtx(e, s)),
          h(s, {
            code: f.too_small,
            minimum: i.value,
            type: "string",
            inclusive: !0,
            exact: !1,
            message: i.message,
          }),
          n.dirty());
      else if (i.kind === "max")
        e.data.length > i.value &&
          ((s = this._getOrReturnCtx(e, s)),
          h(s, {
            code: f.too_big,
            maximum: i.value,
            type: "string",
            inclusive: !0,
            exact: !1,
            message: i.message,
          }),
          n.dirty());
      else if (i.kind === "length") {
        let a = e.data.length > i.value,
          o = e.data.length < i.value;
        (a || o) &&
          ((s = this._getOrReturnCtx(e, s)),
          a
            ? h(s, {
                code: f.too_big,
                maximum: i.value,
                type: "string",
                inclusive: !0,
                exact: !0,
                message: i.message,
              })
            : o &&
              h(s, {
                code: f.too_small,
                minimum: i.value,
                type: "string",
                inclusive: !0,
                exact: !0,
                message: i.message,
              }),
          n.dirty());
      } else if (i.kind === "email")
        ui.test(e.data) ||
          ((s = this._getOrReturnCtx(e, s)),
          h(s, { validation: "email", code: f.invalid_string, message: i.message }),
          n.dirty());
      else if (i.kind === "emoji")
        (Er || (Er = new RegExp(ci, "u")),
          Er.test(e.data) ||
            ((s = this._getOrReturnCtx(e, s)),
            h(s, { validation: "emoji", code: f.invalid_string, message: i.message }),
            n.dirty()));
      else if (i.kind === "uuid")
        ii.test(e.data) ||
          ((s = this._getOrReturnCtx(e, s)),
          h(s, { validation: "uuid", code: f.invalid_string, message: i.message }),
          n.dirty());
      else if (i.kind === "nanoid")
        ai.test(e.data) ||
          ((s = this._getOrReturnCtx(e, s)),
          h(s, { validation: "nanoid", code: f.invalid_string, message: i.message }),
          n.dirty());
      else if (i.kind === "cuid")
        ri.test(e.data) ||
          ((s = this._getOrReturnCtx(e, s)),
          h(s, { validation: "cuid", code: f.invalid_string, message: i.message }),
          n.dirty());
      else if (i.kind === "cuid2")
        ni.test(e.data) ||
          ((s = this._getOrReturnCtx(e, s)),
          h(s, { validation: "cuid2", code: f.invalid_string, message: i.message }),
          n.dirty());
      else if (i.kind === "ulid")
        si.test(e.data) ||
          ((s = this._getOrReturnCtx(e, s)),
          h(s, { validation: "ulid", code: f.invalid_string, message: i.message }),
          n.dirty());
      else if (i.kind === "url")
        try {
          new URL(e.data);
        } catch {
          ((s = this._getOrReturnCtx(e, s)),
            h(s, { validation: "url", code: f.invalid_string, message: i.message }),
            n.dirty());
        }
      else
        i.kind === "regex"
          ? ((i.regex.lastIndex = 0),
            i.regex.test(e.data) ||
              ((s = this._getOrReturnCtx(e, s)),
              h(s, { validation: "regex", code: f.invalid_string, message: i.message }),
              n.dirty()))
          : i.kind === "trim"
            ? (e.data = e.data.trim())
            : i.kind === "includes"
              ? e.data.includes(i.value, i.position) ||
                ((s = this._getOrReturnCtx(e, s)),
                h(s, {
                  code: f.invalid_string,
                  validation: { includes: i.value, position: i.position },
                  message: i.message,
                }),
                n.dirty())
              : i.kind === "toLowerCase"
                ? (e.data = e.data.toLowerCase())
                : i.kind === "toUpperCase"
                  ? (e.data = e.data.toUpperCase())
                  : i.kind === "startsWith"
                    ? e.data.startsWith(i.value) ||
                      ((s = this._getOrReturnCtx(e, s)),
                      h(s, {
                        code: f.invalid_string,
                        validation: { startsWith: i.value },
                        message: i.message,
                      }),
                      n.dirty())
                    : i.kind === "endsWith"
                      ? e.data.endsWith(i.value) ||
                        ((s = this._getOrReturnCtx(e, s)),
                        h(s, {
                          code: f.invalid_string,
                          validation: { endsWith: i.value },
                          message: i.message,
                        }),
                        n.dirty())
                      : i.kind === "datetime"
                        ? On(i).test(e.data) ||
                          ((s = this._getOrReturnCtx(e, s)),
                          h(s, {
                            code: f.invalid_string,
                            validation: "datetime",
                            message: i.message,
                          }),
                          n.dirty())
                        : i.kind === "date"
                          ? gi.test(e.data) ||
                            ((s = this._getOrReturnCtx(e, s)),
                            h(s, {
                              code: f.invalid_string,
                              validation: "date",
                              message: i.message,
                            }),
                            n.dirty())
                          : i.kind === "time"
                            ? vi(i).test(e.data) ||
                              ((s = this._getOrReturnCtx(e, s)),
                              h(s, {
                                code: f.invalid_string,
                                validation: "time",
                                message: i.message,
                              }),
                              n.dirty())
                            : i.kind === "duration"
                              ? li.test(e.data) ||
                                ((s = this._getOrReturnCtx(e, s)),
                                h(s, {
                                  validation: "duration",
                                  code: f.invalid_string,
                                  message: i.message,
                                }),
                                n.dirty())
                              : i.kind === "ip"
                                ? wi(e.data, i.version) ||
                                  ((s = this._getOrReturnCtx(e, s)),
                                  h(s, {
                                    validation: "ip",
                                    code: f.invalid_string,
                                    message: i.message,
                                  }),
                                  n.dirty())
                                : i.kind === "jwt"
                                  ? _i(e.data, i.alg) ||
                                    ((s = this._getOrReturnCtx(e, s)),
                                    h(s, {
                                      validation: "jwt",
                                      code: f.invalid_string,
                                      message: i.message,
                                    }),
                                    n.dirty())
                                  : i.kind === "cidr"
                                    ? Ti(e.data, i.version) ||
                                      ((s = this._getOrReturnCtx(e, s)),
                                      h(s, {
                                        validation: "cidr",
                                        code: f.invalid_string,
                                        message: i.message,
                                      }),
                                      n.dirty())
                                    : i.kind === "base64"
                                      ? pi.test(e.data) ||
                                        ((s = this._getOrReturnCtx(e, s)),
                                        h(s, {
                                          validation: "base64",
                                          code: f.invalid_string,
                                          message: i.message,
                                        }),
                                        n.dirty())
                                      : i.kind === "base64url"
                                        ? yi.test(e.data) ||
                                          ((s = this._getOrReturnCtx(e, s)),
                                          h(s, {
                                            validation: "base64url",
                                            code: f.invalid_string,
                                            message: i.message,
                                          }),
                                          n.dirty())
                                        : x.assertNever(i);
    return { status: n.value, value: e.data };
  }
  _regex(e, r, n) {
    return this.refinement((s) => e.test(s), {
      validation: r,
      code: f.invalid_string,
      ...y.errToObj(n),
    });
  }
  _addCheck(e) {
    return new t({ ...this._def, checks: [...this._def.checks, e] });
  }
  email(e) {
    return this._addCheck({ kind: "email", ...y.errToObj(e) });
  }
  url(e) {
    return this._addCheck({ kind: "url", ...y.errToObj(e) });
  }
  emoji(e) {
    return this._addCheck({ kind: "emoji", ...y.errToObj(e) });
  }
  uuid(e) {
    return this._addCheck({ kind: "uuid", ...y.errToObj(e) });
  }
  nanoid(e) {
    return this._addCheck({ kind: "nanoid", ...y.errToObj(e) });
  }
  cuid(e) {
    return this._addCheck({ kind: "cuid", ...y.errToObj(e) });
  }
  cuid2(e) {
    return this._addCheck({ kind: "cuid2", ...y.errToObj(e) });
  }
  ulid(e) {
    return this._addCheck({ kind: "ulid", ...y.errToObj(e) });
  }
  base64(e) {
    return this._addCheck({ kind: "base64", ...y.errToObj(e) });
  }
  base64url(e) {
    return this._addCheck({ kind: "base64url", ...y.errToObj(e) });
  }
  jwt(e) {
    return this._addCheck({ kind: "jwt", ...y.errToObj(e) });
  }
  ip(e) {
    return this._addCheck({ kind: "ip", ...y.errToObj(e) });
  }
  cidr(e) {
    return this._addCheck({ kind: "cidr", ...y.errToObj(e) });
  }
  datetime(e) {
    var r, n;
    return typeof e == "string"
      ? this._addCheck({ kind: "datetime", precision: null, offset: !1, local: !1, message: e })
      : this._addCheck({
          kind: "datetime",
          precision: typeof e?.precision > "u" ? null : e?.precision,
          offset: (r = e?.offset) !== null && r !== void 0 ? r : !1,
          local: (n = e?.local) !== null && n !== void 0 ? n : !1,
          ...y.errToObj(e?.message),
        });
  }
  date(e) {
    return this._addCheck({ kind: "date", message: e });
  }
  time(e) {
    return typeof e == "string"
      ? this._addCheck({ kind: "time", precision: null, message: e })
      : this._addCheck({
          kind: "time",
          precision: typeof e?.precision > "u" ? null : e?.precision,
          ...y.errToObj(e?.message),
        });
  }
  duration(e) {
    return this._addCheck({ kind: "duration", ...y.errToObj(e) });
  }
  regex(e, r) {
    return this._addCheck({ kind: "regex", regex: e, ...y.errToObj(r) });
  }
  includes(e, r) {
    return this._addCheck({
      kind: "includes",
      value: e,
      position: r?.position,
      ...y.errToObj(r?.message),
    });
  }
  startsWith(e, r) {
    return this._addCheck({ kind: "startsWith", value: e, ...y.errToObj(r) });
  }
  endsWith(e, r) {
    return this._addCheck({ kind: "endsWith", value: e, ...y.errToObj(r) });
  }
  min(e, r) {
    return this._addCheck({ kind: "min", value: e, ...y.errToObj(r) });
  }
  max(e, r) {
    return this._addCheck({ kind: "max", value: e, ...y.errToObj(r) });
  }
  length(e, r) {
    return this._addCheck({ kind: "length", value: e, ...y.errToObj(r) });
  }
  nonempty(e) {
    return this.min(1, y.errToObj(e));
  }
  trim() {
    return new t({ ...this._def, checks: [...this._def.checks, { kind: "trim" }] });
  }
  toLowerCase() {
    return new t({ ...this._def, checks: [...this._def.checks, { kind: "toLowerCase" }] });
  }
  toUpperCase() {
    return new t({ ...this._def, checks: [...this._def.checks, { kind: "toUpperCase" }] });
  }
  get isDatetime() {
    return !!this._def.checks.find((e) => e.kind === "datetime");
  }
  get isDate() {
    return !!this._def.checks.find((e) => e.kind === "date");
  }
  get isTime() {
    return !!this._def.checks.find((e) => e.kind === "time");
  }
  get isDuration() {
    return !!this._def.checks.find((e) => e.kind === "duration");
  }
  get isEmail() {
    return !!this._def.checks.find((e) => e.kind === "email");
  }
  get isURL() {
    return !!this._def.checks.find((e) => e.kind === "url");
  }
  get isEmoji() {
    return !!this._def.checks.find((e) => e.kind === "emoji");
  }
  get isUUID() {
    return !!this._def.checks.find((e) => e.kind === "uuid");
  }
  get isNANOID() {
    return !!this._def.checks.find((e) => e.kind === "nanoid");
  }
  get isCUID() {
    return !!this._def.checks.find((e) => e.kind === "cuid");
  }
  get isCUID2() {
    return !!this._def.checks.find((e) => e.kind === "cuid2");
  }
  get isULID() {
    return !!this._def.checks.find((e) => e.kind === "ulid");
  }
  get isIP() {
    return !!this._def.checks.find((e) => e.kind === "ip");
  }
  get isCIDR() {
    return !!this._def.checks.find((e) => e.kind === "cidr");
  }
  get isBase64() {
    return !!this._def.checks.find((e) => e.kind === "base64");
  }
  get isBase64url() {
    return !!this._def.checks.find((e) => e.kind === "base64url");
  }
  get minLength() {
    let e = null;
    for (let r of this._def.checks)
      r.kind === "min" && (e === null || r.value > e) && (e = r.value);
    return e;
  }
  get maxLength() {
    let e = null;
    for (let r of this._def.checks)
      r.kind === "max" && (e === null || r.value < e) && (e = r.value);
    return e;
  }
};
ye.create = (t) => {
  var e;
  return new ye({
    checks: [],
    typeName: _.ZodString,
    coerce: (e = t?.coerce) !== null && e !== void 0 ? e : !1,
    ...b(t),
  });
};
function bi(t, e) {
  let r = (t.toString().split(".")[1] || "").length,
    n = (e.toString().split(".")[1] || "").length,
    s = r > n ? r : n,
    i = parseInt(t.toFixed(s).replace(".", "")),
    a = parseInt(e.toFixed(s).replace(".", ""));
  return (i % a) / Math.pow(10, s);
}
var Oe = class t extends k {
  constructor() {
    (super(...arguments),
      (this.min = this.gte),
      (this.max = this.lte),
      (this.step = this.multipleOf));
  }
  _parse(e) {
    if ((this._def.coerce && (e.data = Number(e.data)), this._getType(e) !== p.number)) {
      let i = this._getOrReturnCtx(e);
      return (h(i, { code: f.invalid_type, expected: p.number, received: i.parsedType }), T);
    }
    let n,
      s = new R();
    for (let i of this._def.checks)
      i.kind === "int"
        ? x.isInteger(e.data) ||
          ((n = this._getOrReturnCtx(e, n)),
          h(n, {
            code: f.invalid_type,
            expected: "integer",
            received: "float",
            message: i.message,
          }),
          s.dirty())
        : i.kind === "min"
          ? (i.inclusive ? e.data < i.value : e.data <= i.value) &&
            ((n = this._getOrReturnCtx(e, n)),
            h(n, {
              code: f.too_small,
              minimum: i.value,
              type: "number",
              inclusive: i.inclusive,
              exact: !1,
              message: i.message,
            }),
            s.dirty())
          : i.kind === "max"
            ? (i.inclusive ? e.data > i.value : e.data >= i.value) &&
              ((n = this._getOrReturnCtx(e, n)),
              h(n, {
                code: f.too_big,
                maximum: i.value,
                type: "number",
                inclusive: i.inclusive,
                exact: !1,
                message: i.message,
              }),
              s.dirty())
            : i.kind === "multipleOf"
              ? bi(e.data, i.value) !== 0 &&
                ((n = this._getOrReturnCtx(e, n)),
                h(n, { code: f.not_multiple_of, multipleOf: i.value, message: i.message }),
                s.dirty())
              : i.kind === "finite"
                ? Number.isFinite(e.data) ||
                  ((n = this._getOrReturnCtx(e, n)),
                  h(n, { code: f.not_finite, message: i.message }),
                  s.dirty())
                : x.assertNever(i);
    return { status: s.value, value: e.data };
  }
  gte(e, r) {
    return this.setLimit("min", e, !0, y.toString(r));
  }
  gt(e, r) {
    return this.setLimit("min", e, !1, y.toString(r));
  }
  lte(e, r) {
    return this.setLimit("max", e, !0, y.toString(r));
  }
  lt(e, r) {
    return this.setLimit("max", e, !1, y.toString(r));
  }
  setLimit(e, r, n, s) {
    return new t({
      ...this._def,
      checks: [...this._def.checks, { kind: e, value: r, inclusive: n, message: y.toString(s) }],
    });
  }
  _addCheck(e) {
    return new t({ ...this._def, checks: [...this._def.checks, e] });
  }
  int(e) {
    return this._addCheck({ kind: "int", message: y.toString(e) });
  }
  positive(e) {
    return this._addCheck({ kind: "min", value: 0, inclusive: !1, message: y.toString(e) });
  }
  negative(e) {
    return this._addCheck({ kind: "max", value: 0, inclusive: !1, message: y.toString(e) });
  }
  nonpositive(e) {
    return this._addCheck({ kind: "max", value: 0, inclusive: !0, message: y.toString(e) });
  }
  nonnegative(e) {
    return this._addCheck({ kind: "min", value: 0, inclusive: !0, message: y.toString(e) });
  }
  multipleOf(e, r) {
    return this._addCheck({ kind: "multipleOf", value: e, message: y.toString(r) });
  }
  finite(e) {
    return this._addCheck({ kind: "finite", message: y.toString(e) });
  }
  safe(e) {
    return this._addCheck({
      kind: "min",
      inclusive: !0,
      value: Number.MIN_SAFE_INTEGER,
      message: y.toString(e),
    })._addCheck({
      kind: "max",
      inclusive: !0,
      value: Number.MAX_SAFE_INTEGER,
      message: y.toString(e),
    });
  }
  get minValue() {
    let e = null;
    for (let r of this._def.checks)
      r.kind === "min" && (e === null || r.value > e) && (e = r.value);
    return e;
  }
  get maxValue() {
    let e = null;
    for (let r of this._def.checks)
      r.kind === "max" && (e === null || r.value < e) && (e = r.value);
    return e;
  }
  get isInt() {
    return !!this._def.checks.find(
      (e) => e.kind === "int" || (e.kind === "multipleOf" && x.isInteger(e.value)),
    );
  }
  get isFinite() {
    let e = null,
      r = null;
    for (let n of this._def.checks) {
      if (n.kind === "finite" || n.kind === "int" || n.kind === "multipleOf") return !0;
      n.kind === "min"
        ? (r === null || n.value > r) && (r = n.value)
        : n.kind === "max" && (e === null || n.value < e) && (e = n.value);
    }
    return Number.isFinite(r) && Number.isFinite(e);
  }
};
Oe.create = (t) => new Oe({ checks: [], typeName: _.ZodNumber, coerce: t?.coerce || !1, ...b(t) });
var Ie = class t extends k {
  constructor() {
    (super(...arguments), (this.min = this.gte), (this.max = this.lte));
  }
  _parse(e) {
    if (this._def.coerce)
      try {
        e.data = BigInt(e.data);
      } catch {
        return this._getInvalidInput(e);
      }
    if (this._getType(e) !== p.bigint) return this._getInvalidInput(e);
    let n,
      s = new R();
    for (let i of this._def.checks)
      i.kind === "min"
        ? (i.inclusive ? e.data < i.value : e.data <= i.value) &&
          ((n = this._getOrReturnCtx(e, n)),
          h(n, {
            code: f.too_small,
            type: "bigint",
            minimum: i.value,
            inclusive: i.inclusive,
            message: i.message,
          }),
          s.dirty())
        : i.kind === "max"
          ? (i.inclusive ? e.data > i.value : e.data >= i.value) &&
            ((n = this._getOrReturnCtx(e, n)),
            h(n, {
              code: f.too_big,
              type: "bigint",
              maximum: i.value,
              inclusive: i.inclusive,
              message: i.message,
            }),
            s.dirty())
          : i.kind === "multipleOf"
            ? e.data % i.value !== BigInt(0) &&
              ((n = this._getOrReturnCtx(e, n)),
              h(n, { code: f.not_multiple_of, multipleOf: i.value, message: i.message }),
              s.dirty())
            : x.assertNever(i);
    return { status: s.value, value: e.data };
  }
  _getInvalidInput(e) {
    let r = this._getOrReturnCtx(e);
    return (h(r, { code: f.invalid_type, expected: p.bigint, received: r.parsedType }), T);
  }
  gte(e, r) {
    return this.setLimit("min", e, !0, y.toString(r));
  }
  gt(e, r) {
    return this.setLimit("min", e, !1, y.toString(r));
  }
  lte(e, r) {
    return this.setLimit("max", e, !0, y.toString(r));
  }
  lt(e, r) {
    return this.setLimit("max", e, !1, y.toString(r));
  }
  setLimit(e, r, n, s) {
    return new t({
      ...this._def,
      checks: [...this._def.checks, { kind: e, value: r, inclusive: n, message: y.toString(s) }],
    });
  }
  _addCheck(e) {
    return new t({ ...this._def, checks: [...this._def.checks, e] });
  }
  positive(e) {
    return this._addCheck({ kind: "min", value: BigInt(0), inclusive: !1, message: y.toString(e) });
  }
  negative(e) {
    return this._addCheck({ kind: "max", value: BigInt(0), inclusive: !1, message: y.toString(e) });
  }
  nonpositive(e) {
    return this._addCheck({ kind: "max", value: BigInt(0), inclusive: !0, message: y.toString(e) });
  }
  nonnegative(e) {
    return this._addCheck({ kind: "min", value: BigInt(0), inclusive: !0, message: y.toString(e) });
  }
  multipleOf(e, r) {
    return this._addCheck({ kind: "multipleOf", value: e, message: y.toString(r) });
  }
  get minValue() {
    let e = null;
    for (let r of this._def.checks)
      r.kind === "min" && (e === null || r.value > e) && (e = r.value);
    return e;
  }
  get maxValue() {
    let e = null;
    for (let r of this._def.checks)
      r.kind === "max" && (e === null || r.value < e) && (e = r.value);
    return e;
  }
};
Ie.create = (t) => {
  var e;
  return new Ie({
    checks: [],
    typeName: _.ZodBigInt,
    coerce: (e = t?.coerce) !== null && e !== void 0 ? e : !1,
    ...b(t),
  });
};
var De = class extends k {
  _parse(e) {
    if ((this._def.coerce && (e.data = !!e.data), this._getType(e) !== p.boolean)) {
      let n = this._getOrReturnCtx(e);
      return (h(n, { code: f.invalid_type, expected: p.boolean, received: n.parsedType }), T);
    }
    return P(e.data);
  }
};
De.create = (t) => new De({ typeName: _.ZodBoolean, coerce: t?.coerce || !1, ...b(t) });
var Me = class t extends k {
  _parse(e) {
    if ((this._def.coerce && (e.data = new Date(e.data)), this._getType(e) !== p.date)) {
      let i = this._getOrReturnCtx(e);
      return (h(i, { code: f.invalid_type, expected: p.date, received: i.parsedType }), T);
    }
    if (isNaN(e.data.getTime())) {
      let i = this._getOrReturnCtx(e);
      return (h(i, { code: f.invalid_date }), T);
    }
    let n = new R(),
      s;
    for (let i of this._def.checks)
      i.kind === "min"
        ? e.data.getTime() < i.value &&
          ((s = this._getOrReturnCtx(e, s)),
          h(s, {
            code: f.too_small,
            message: i.message,
            inclusive: !0,
            exact: !1,
            minimum: i.value,
            type: "date",
          }),
          n.dirty())
        : i.kind === "max"
          ? e.data.getTime() > i.value &&
            ((s = this._getOrReturnCtx(e, s)),
            h(s, {
              code: f.too_big,
              message: i.message,
              inclusive: !0,
              exact: !1,
              maximum: i.value,
              type: "date",
            }),
            n.dirty())
          : x.assertNever(i);
    return { status: n.value, value: new Date(e.data.getTime()) };
  }
  _addCheck(e) {
    return new t({ ...this._def, checks: [...this._def.checks, e] });
  }
  min(e, r) {
    return this._addCheck({ kind: "min", value: e.getTime(), message: y.toString(r) });
  }
  max(e, r) {
    return this._addCheck({ kind: "max", value: e.getTime(), message: y.toString(r) });
  }
  get minDate() {
    let e = null;
    for (let r of this._def.checks)
      r.kind === "min" && (e === null || r.value > e) && (e = r.value);
    return e != null ? new Date(e) : null;
  }
  get maxDate() {
    let e = null;
    for (let r of this._def.checks)
      r.kind === "max" && (e === null || r.value < e) && (e = r.value);
    return e != null ? new Date(e) : null;
  }
};
Me.create = (t) => new Me({ checks: [], coerce: t?.coerce || !1, typeName: _.ZodDate, ...b(t) });
var Qe = class extends k {
  _parse(e) {
    if (this._getType(e) !== p.symbol) {
      let n = this._getOrReturnCtx(e);
      return (h(n, { code: f.invalid_type, expected: p.symbol, received: n.parsedType }), T);
    }
    return P(e.data);
  }
};
Qe.create = (t) => new Qe({ typeName: _.ZodSymbol, ...b(t) });
var Ne = class extends k {
  _parse(e) {
    if (this._getType(e) !== p.undefined) {
      let n = this._getOrReturnCtx(e);
      return (h(n, { code: f.invalid_type, expected: p.undefined, received: n.parsedType }), T);
    }
    return P(e.data);
  }
};
Ne.create = (t) => new Ne({ typeName: _.ZodUndefined, ...b(t) });
var Ce = class extends k {
  _parse(e) {
    if (this._getType(e) !== p.null) {
      let n = this._getOrReturnCtx(e);
      return (h(n, { code: f.invalid_type, expected: p.null, received: n.parsedType }), T);
    }
    return P(e.data);
  }
};
Ce.create = (t) => new Ce({ typeName: _.ZodNull, ...b(t) });
var ge = class extends k {
  constructor() {
    (super(...arguments), (this._any = !0));
  }
  _parse(e) {
    return P(e.data);
  }
};
ge.create = (t) => new ge({ typeName: _.ZodAny, ...b(t) });
var ce = class extends k {
  constructor() {
    (super(...arguments), (this._unknown = !0));
  }
  _parse(e) {
    return P(e.data);
  }
};
ce.create = (t) => new ce({ typeName: _.ZodUnknown, ...b(t) });
var K = class extends k {
  _parse(e) {
    let r = this._getOrReturnCtx(e);
    return (h(r, { code: f.invalid_type, expected: p.never, received: r.parsedType }), T);
  }
};
K.create = (t) => new K({ typeName: _.ZodNever, ...b(t) });
var Xe = class extends k {
  _parse(e) {
    if (this._getType(e) !== p.undefined) {
      let n = this._getOrReturnCtx(e);
      return (h(n, { code: f.invalid_type, expected: p.void, received: n.parsedType }), T);
    }
    return P(e.data);
  }
};
Xe.create = (t) => new Xe({ typeName: _.ZodVoid, ...b(t) });
var de = class t extends k {
  _parse(e) {
    let { ctx: r, status: n } = this._processInputParams(e),
      s = this._def;
    if (r.parsedType !== p.array)
      return (h(r, { code: f.invalid_type, expected: p.array, received: r.parsedType }), T);
    if (s.exactLength !== null) {
      let a = r.data.length > s.exactLength.value,
        o = r.data.length < s.exactLength.value;
      (a || o) &&
        (h(r, {
          code: a ? f.too_big : f.too_small,
          minimum: o ? s.exactLength.value : void 0,
          maximum: a ? s.exactLength.value : void 0,
          type: "array",
          inclusive: !0,
          exact: !0,
          message: s.exactLength.message,
        }),
        n.dirty());
    }
    if (
      (s.minLength !== null &&
        r.data.length < s.minLength.value &&
        (h(r, {
          code: f.too_small,
          minimum: s.minLength.value,
          type: "array",
          inclusive: !0,
          exact: !1,
          message: s.minLength.message,
        }),
        n.dirty()),
      s.maxLength !== null &&
        r.data.length > s.maxLength.value &&
        (h(r, {
          code: f.too_big,
          maximum: s.maxLength.value,
          type: "array",
          inclusive: !0,
          exact: !1,
          message: s.maxLength.message,
        }),
        n.dirty()),
      r.common.async)
    )
      return Promise.all(
        [...r.data].map((a, o) => s.type._parseAsync(new Y(r, a, r.path, o))),
      ).then((a) => R.mergeArray(n, a));
    let i = [...r.data].map((a, o) => s.type._parseSync(new Y(r, a, r.path, o)));
    return R.mergeArray(n, i);
  }
  get element() {
    return this._def.type;
  }
  min(e, r) {
    return new t({ ...this._def, minLength: { value: e, message: y.toString(r) } });
  }
  max(e, r) {
    return new t({ ...this._def, maxLength: { value: e, message: y.toString(r) } });
  }
  length(e, r) {
    return new t({ ...this._def, exactLength: { value: e, message: y.toString(r) } });
  }
  nonempty(e) {
    return this.min(1, e);
  }
};
de.create = (t, e) =>
  new de({
    type: t,
    minLength: null,
    maxLength: null,
    exactLength: null,
    typeName: _.ZodArray,
    ...b(e),
  });
function Be(t) {
  if (t instanceof z) {
    let e = {};
    for (let r in t.shape) {
      let n = t.shape[r];
      e[r] = G.create(Be(n));
    }
    return new z({ ...t._def, shape: () => e });
  } else
    return t instanceof de
      ? new de({ ...t._def, type: Be(t.element) })
      : t instanceof G
        ? G.create(Be(t.unwrap()))
        : t instanceof ae
          ? ae.create(Be(t.unwrap()))
          : t instanceof ie
            ? ie.create(t.items.map((e) => Be(e)))
            : t;
}
var z = class t extends k {
  constructor() {
    (super(...arguments),
      (this._cached = null),
      (this.nonstrict = this.passthrough),
      (this.augment = this.extend));
  }
  _getCached() {
    if (this._cached !== null) return this._cached;
    let e = this._def.shape(),
      r = x.objectKeys(e);
    return (this._cached = { shape: e, keys: r });
  }
  _parse(e) {
    if (this._getType(e) !== p.object) {
      let u = this._getOrReturnCtx(e);
      return (h(u, { code: f.invalid_type, expected: p.object, received: u.parsedType }), T);
    }
    let { status: n, ctx: s } = this._processInputParams(e),
      { shape: i, keys: a } = this._getCached(),
      o = [];
    if (!(this._def.catchall instanceof K && this._def.unknownKeys === "strip"))
      for (let u in s.data) a.includes(u) || o.push(u);
    let l = [];
    for (let u of a) {
      let d = i[u],
        g = s.data[u];
      l.push({
        key: { status: "valid", value: u },
        value: d._parse(new Y(s, g, s.path, u)),
        alwaysSet: u in s.data,
      });
    }
    if (this._def.catchall instanceof K) {
      let u = this._def.unknownKeys;
      if (u === "passthrough")
        for (let d of o)
          l.push({
            key: { status: "valid", value: d },
            value: { status: "valid", value: s.data[d] },
          });
      else if (u === "strict")
        o.length > 0 && (h(s, { code: f.unrecognized_keys, keys: o }), n.dirty());
      else if (u !== "strip")
        throw new Error("Internal ZodObject error: invalid unknownKeys value.");
    } else {
      let u = this._def.catchall;
      for (let d of o) {
        let g = s.data[d];
        l.push({
          key: { status: "valid", value: d },
          value: u._parse(new Y(s, g, s.path, d)),
          alwaysSet: d in s.data,
        });
      }
    }
    return s.common.async
      ? Promise.resolve()
          .then(async () => {
            let u = [];
            for (let d of l) {
              let g = await d.key,
                D = await d.value;
              u.push({ key: g, value: D, alwaysSet: d.alwaysSet });
            }
            return u;
          })
          .then((u) => R.mergeObjectSync(n, u))
      : R.mergeObjectSync(n, l);
  }
  get shape() {
    return this._def.shape();
  }
  strict(e) {
    return (
      y.errToObj,
      new t({
        ...this._def,
        unknownKeys: "strict",
        ...(e !== void 0
          ? {
              errorMap: (r, n) => {
                var s, i, a, o;
                let l =
                  (a =
                    (i = (s = this._def).errorMap) === null || i === void 0
                      ? void 0
                      : i.call(s, r, n).message) !== null && a !== void 0
                    ? a
                    : n.defaultError;
                return r.code === "unrecognized_keys"
                  ? { message: (o = y.errToObj(e).message) !== null && o !== void 0 ? o : l }
                  : { message: l };
              },
            }
          : {}),
      })
    );
  }
  strip() {
    return new t({ ...this._def, unknownKeys: "strip" });
  }
  passthrough() {
    return new t({ ...this._def, unknownKeys: "passthrough" });
  }
  extend(e) {
    return new t({ ...this._def, shape: () => ({ ...this._def.shape(), ...e }) });
  }
  merge(e) {
    return new t({
      unknownKeys: e._def.unknownKeys,
      catchall: e._def.catchall,
      shape: () => ({ ...this._def.shape(), ...e._def.shape() }),
      typeName: _.ZodObject,
    });
  }
  setKey(e, r) {
    return this.augment({ [e]: r });
  }
  catchall(e) {
    return new t({ ...this._def, catchall: e });
  }
  pick(e) {
    let r = {};
    return (
      x.objectKeys(e).forEach((n) => {
        e[n] && this.shape[n] && (r[n] = this.shape[n]);
      }),
      new t({ ...this._def, shape: () => r })
    );
  }
  omit(e) {
    let r = {};
    return (
      x.objectKeys(this.shape).forEach((n) => {
        e[n] || (r[n] = this.shape[n]);
      }),
      new t({ ...this._def, shape: () => r })
    );
  }
  deepPartial() {
    return Be(this);
  }
  partial(e) {
    let r = {};
    return (
      x.objectKeys(this.shape).forEach((n) => {
        let s = this.shape[n];
        e && !e[n] ? (r[n] = s) : (r[n] = s.optional());
      }),
      new t({ ...this._def, shape: () => r })
    );
  }
  required(e) {
    let r = {};
    return (
      x.objectKeys(this.shape).forEach((n) => {
        if (e && !e[n]) r[n] = this.shape[n];
        else {
          let i = this.shape[n];
          for (; i instanceof G; ) i = i._def.innerType;
          r[n] = i;
        }
      }),
      new t({ ...this._def, shape: () => r })
    );
  }
  keyof() {
    return In(x.objectKeys(this.shape));
  }
};
z.create = (t, e) =>
  new z({
    shape: () => t,
    unknownKeys: "strip",
    catchall: K.create(),
    typeName: _.ZodObject,
    ...b(e),
  });
z.strictCreate = (t, e) =>
  new z({
    shape: () => t,
    unknownKeys: "strict",
    catchall: K.create(),
    typeName: _.ZodObject,
    ...b(e),
  });
z.lazycreate = (t, e) =>
  new z({ shape: t, unknownKeys: "strip", catchall: K.create(), typeName: _.ZodObject, ...b(e) });
var Ae = class extends k {
  _parse(e) {
    let { ctx: r } = this._processInputParams(e),
      n = this._def.options;
    function s(i) {
      for (let o of i) if (o.result.status === "valid") return o.result;
      for (let o of i)
        if (o.result.status === "dirty")
          return (r.common.issues.push(...o.ctx.common.issues), o.result);
      let a = i.map((o) => new $(o.ctx.common.issues));
      return (h(r, { code: f.invalid_union, unionErrors: a }), T);
    }
    if (r.common.async)
      return Promise.all(
        n.map(async (i) => {
          let a = { ...r, common: { ...r.common, issues: [] }, parent: null };
          return { result: await i._parseAsync({ data: r.data, path: r.path, parent: a }), ctx: a };
        }),
      ).then(s);
    {
      let i,
        a = [];
      for (let l of n) {
        let u = { ...r, common: { ...r.common, issues: [] }, parent: null },
          d = l._parseSync({ data: r.data, path: r.path, parent: u });
        if (d.status === "valid") return d;
        (d.status === "dirty" && !i && (i = { result: d, ctx: u }),
          u.common.issues.length && a.push(u.common.issues));
      }
      if (i) return (r.common.issues.push(...i.ctx.common.issues), i.result);
      let o = a.map((l) => new $(l));
      return (h(r, { code: f.invalid_union, unionErrors: o }), T);
    }
  }
  get options() {
    return this._def.options;
  }
};
Ae.create = (t, e) => new Ae({ options: t, typeName: _.ZodUnion, ...b(e) });
var le = (t) =>
    t instanceof We
      ? le(t.schema)
      : t instanceof j
        ? le(t.innerType())
        : t instanceof Le
          ? [t.value]
          : t instanceof Re
            ? t.options
            : t instanceof Ze
              ? x.objectValues(t.enum)
              : t instanceof Pe
                ? le(t._def.innerType)
                : t instanceof Ne
                  ? [void 0]
                  : t instanceof Ce
                    ? [null]
                    : t instanceof G
                      ? [void 0, ...le(t.unwrap())]
                      : t instanceof ae
                        ? [null, ...le(t.unwrap())]
                        : t instanceof bt || t instanceof Ve
                          ? le(t.unwrap())
                          : t instanceof ze
                            ? le(t._def.innerType)
                            : [],
  nr = class t extends k {
    _parse(e) {
      let { ctx: r } = this._processInputParams(e);
      if (r.parsedType !== p.object)
        return (h(r, { code: f.invalid_type, expected: p.object, received: r.parsedType }), T);
      let n = this.discriminator,
        s = r.data[n],
        i = this.optionsMap.get(s);
      return i
        ? r.common.async
          ? i._parseAsync({ data: r.data, path: r.path, parent: r })
          : i._parseSync({ data: r.data, path: r.path, parent: r })
        : (h(r, {
            code: f.invalid_union_discriminator,
            options: Array.from(this.optionsMap.keys()),
            path: [n],
          }),
          T);
    }
    get discriminator() {
      return this._def.discriminator;
    }
    get options() {
      return this._def.options;
    }
    get optionsMap() {
      return this._def.optionsMap;
    }
    static create(e, r, n) {
      let s = new Map();
      for (let i of r) {
        let a = le(i.shape[e]);
        if (!a.length)
          throw new Error(
            `A discriminator value for key \`${e}\` could not be extracted from all schema options`,
          );
        for (let o of a) {
          if (s.has(o))
            throw new Error(`Discriminator property ${String(e)} has duplicate value ${String(o)}`);
          s.set(o, i);
        }
      }
      return new t({
        typeName: _.ZodDiscriminatedUnion,
        discriminator: e,
        options: r,
        optionsMap: s,
        ...b(n),
      });
    }
  };
function Mr(t, e) {
  let r = ue(t),
    n = ue(e);
  if (t === e) return { valid: !0, data: t };
  if (r === p.object && n === p.object) {
    let s = x.objectKeys(e),
      i = x.objectKeys(t).filter((o) => s.indexOf(o) !== -1),
      a = { ...t, ...e };
    for (let o of i) {
      let l = Mr(t[o], e[o]);
      if (!l.valid) return { valid: !1 };
      a[o] = l.data;
    }
    return { valid: !0, data: a };
  } else if (r === p.array && n === p.array) {
    if (t.length !== e.length) return { valid: !1 };
    let s = [];
    for (let i = 0; i < t.length; i++) {
      let a = t[i],
        o = e[i],
        l = Mr(a, o);
      if (!l.valid) return { valid: !1 };
      s.push(l.data);
    }
    return { valid: !0, data: s };
  } else return r === p.date && n === p.date && +t == +e ? { valid: !0, data: t } : { valid: !1 };
}
var Fe = class extends k {
  _parse(e) {
    let { status: r, ctx: n } = this._processInputParams(e),
      s = (i, a) => {
        if (Ir(i) || Ir(a)) return T;
        let o = Mr(i.value, a.value);
        return o.valid
          ? ((Dr(i) || Dr(a)) && r.dirty(), { status: r.value, value: o.data })
          : (h(n, { code: f.invalid_intersection_types }), T);
      };
    return n.common.async
      ? Promise.all([
          this._def.left._parseAsync({ data: n.data, path: n.path, parent: n }),
          this._def.right._parseAsync({ data: n.data, path: n.path, parent: n }),
        ]).then(([i, a]) => s(i, a))
      : s(
          this._def.left._parseSync({ data: n.data, path: n.path, parent: n }),
          this._def.right._parseSync({ data: n.data, path: n.path, parent: n }),
        );
  }
};
Fe.create = (t, e, r) => new Fe({ left: t, right: e, typeName: _.ZodIntersection, ...b(r) });
var ie = class t extends k {
  _parse(e) {
    let { status: r, ctx: n } = this._processInputParams(e);
    if (n.parsedType !== p.array)
      return (h(n, { code: f.invalid_type, expected: p.array, received: n.parsedType }), T);
    if (n.data.length < this._def.items.length)
      return (
        h(n, {
          code: f.too_small,
          minimum: this._def.items.length,
          inclusive: !0,
          exact: !1,
          type: "array",
        }),
        T
      );
    !this._def.rest &&
      n.data.length > this._def.items.length &&
      (h(n, {
        code: f.too_big,
        maximum: this._def.items.length,
        inclusive: !0,
        exact: !1,
        type: "array",
      }),
      r.dirty());
    let i = [...n.data]
      .map((a, o) => {
        let l = this._def.items[o] || this._def.rest;
        return l ? l._parse(new Y(n, a, n.path, o)) : null;
      })
      .filter((a) => !!a);
    return n.common.async ? Promise.all(i).then((a) => R.mergeArray(r, a)) : R.mergeArray(r, i);
  }
  get items() {
    return this._def.items;
  }
  rest(e) {
    return new t({ ...this._def, rest: e });
  }
};
ie.create = (t, e) => {
  if (!Array.isArray(t)) throw new Error("You must pass an array of schemas to z.tuple([ ... ])");
  return new ie({ items: t, typeName: _.ZodTuple, rest: null, ...b(e) });
};
var sr = class t extends k {
    get keySchema() {
      return this._def.keyType;
    }
    get valueSchema() {
      return this._def.valueType;
    }
    _parse(e) {
      let { status: r, ctx: n } = this._processInputParams(e);
      if (n.parsedType !== p.object)
        return (h(n, { code: f.invalid_type, expected: p.object, received: n.parsedType }), T);
      let s = [],
        i = this._def.keyType,
        a = this._def.valueType;
      for (let o in n.data)
        s.push({
          key: i._parse(new Y(n, o, n.path, o)),
          value: a._parse(new Y(n, n.data[o], n.path, o)),
          alwaysSet: o in n.data,
        });
      return n.common.async ? R.mergeObjectAsync(r, s) : R.mergeObjectSync(r, s);
    }
    get element() {
      return this._def.valueType;
    }
    static create(e, r, n) {
      return r instanceof k
        ? new t({ keyType: e, valueType: r, typeName: _.ZodRecord, ...b(n) })
        : new t({ keyType: ye.create(), valueType: e, typeName: _.ZodRecord, ...b(r) });
    }
  },
  et = class extends k {
    get keySchema() {
      return this._def.keyType;
    }
    get valueSchema() {
      return this._def.valueType;
    }
    _parse(e) {
      let { status: r, ctx: n } = this._processInputParams(e);
      if (n.parsedType !== p.map)
        return (h(n, { code: f.invalid_type, expected: p.map, received: n.parsedType }), T);
      let s = this._def.keyType,
        i = this._def.valueType,
        a = [...n.data.entries()].map(([o, l], u) => ({
          key: s._parse(new Y(n, o, n.path, [u, "key"])),
          value: i._parse(new Y(n, l, n.path, [u, "value"])),
        }));
      if (n.common.async) {
        let o = new Map();
        return Promise.resolve().then(async () => {
          for (let l of a) {
            let u = await l.key,
              d = await l.value;
            if (u.status === "aborted" || d.status === "aborted") return T;
            ((u.status === "dirty" || d.status === "dirty") && r.dirty(), o.set(u.value, d.value));
          }
          return { status: r.value, value: o };
        });
      } else {
        let o = new Map();
        for (let l of a) {
          let u = l.key,
            d = l.value;
          if (u.status === "aborted" || d.status === "aborted") return T;
          ((u.status === "dirty" || d.status === "dirty") && r.dirty(), o.set(u.value, d.value));
        }
        return { status: r.value, value: o };
      }
    }
  };
et.create = (t, e, r) => new et({ valueType: e, keyType: t, typeName: _.ZodMap, ...b(r) });
var tt = class t extends k {
  _parse(e) {
    let { status: r, ctx: n } = this._processInputParams(e);
    if (n.parsedType !== p.set)
      return (h(n, { code: f.invalid_type, expected: p.set, received: n.parsedType }), T);
    let s = this._def;
    (s.minSize !== null &&
      n.data.size < s.minSize.value &&
      (h(n, {
        code: f.too_small,
        minimum: s.minSize.value,
        type: "set",
        inclusive: !0,
        exact: !1,
        message: s.minSize.message,
      }),
      r.dirty()),
      s.maxSize !== null &&
        n.data.size > s.maxSize.value &&
        (h(n, {
          code: f.too_big,
          maximum: s.maxSize.value,
          type: "set",
          inclusive: !0,
          exact: !1,
          message: s.maxSize.message,
        }),
        r.dirty()));
    let i = this._def.valueType;
    function a(l) {
      let u = new Set();
      for (let d of l) {
        if (d.status === "aborted") return T;
        (d.status === "dirty" && r.dirty(), u.add(d.value));
      }
      return { status: r.value, value: u };
    }
    let o = [...n.data.values()].map((l, u) => i._parse(new Y(n, l, n.path, u)));
    return n.common.async ? Promise.all(o).then((l) => a(l)) : a(o);
  }
  min(e, r) {
    return new t({ ...this._def, minSize: { value: e, message: y.toString(r) } });
  }
  max(e, r) {
    return new t({ ...this._def, maxSize: { value: e, message: y.toString(r) } });
  }
  size(e, r) {
    return this.min(e, r).max(e, r);
  }
  nonempty(e) {
    return this.min(1, e);
  }
};
tt.create = (t, e) =>
  new tt({ valueType: t, minSize: null, maxSize: null, typeName: _.ZodSet, ...b(e) });
var ir = class t extends k {
    constructor() {
      (super(...arguments), (this.validate = this.implement));
    }
    _parse(e) {
      let { ctx: r } = this._processInputParams(e);
      if (r.parsedType !== p.function)
        return (h(r, { code: f.invalid_type, expected: p.function, received: r.parsedType }), T);
      function n(o, l) {
        return tr({
          data: o,
          path: r.path,
          errorMaps: [r.common.contextualErrorMap, r.schemaErrorMap, er(), Ke].filter((u) => !!u),
          issueData: { code: f.invalid_arguments, argumentsError: l },
        });
      }
      function s(o, l) {
        return tr({
          data: o,
          path: r.path,
          errorMaps: [r.common.contextualErrorMap, r.schemaErrorMap, er(), Ke].filter((u) => !!u),
          issueData: { code: f.invalid_return_type, returnTypeError: l },
        });
      }
      let i = { errorMap: r.common.contextualErrorMap },
        a = r.data;
      if (this._def.returns instanceof ve) {
        let o = this;
        return P(async function (...l) {
          let u = new $([]),
            d = await o._def.args.parseAsync(l, i).catch((w) => {
              throw (u.addIssue(n(l, w)), u);
            }),
            g = await Reflect.apply(a, this, d);
          return await o._def.returns._def.type.parseAsync(g, i).catch((w) => {
            throw (u.addIssue(s(g, w)), u);
          });
        });
      } else {
        let o = this;
        return P(function (...l) {
          let u = o._def.args.safeParse(l, i);
          if (!u.success) throw new $([n(l, u.error)]);
          let d = Reflect.apply(a, this, u.data),
            g = o._def.returns.safeParse(d, i);
          if (!g.success) throw new $([s(d, g.error)]);
          return g.data;
        });
      }
    }
    parameters() {
      return this._def.args;
    }
    returnType() {
      return this._def.returns;
    }
    args(...e) {
      return new t({ ...this._def, args: ie.create(e).rest(ce.create()) });
    }
    returns(e) {
      return new t({ ...this._def, returns: e });
    }
    implement(e) {
      return this.parse(e);
    }
    strictImplement(e) {
      return this.parse(e);
    }
    static create(e, r, n) {
      return new t({
        args: e || ie.create([]).rest(ce.create()),
        returns: r || ce.create(),
        typeName: _.ZodFunction,
        ...b(n),
      });
    }
  },
  We = class extends k {
    get schema() {
      return this._def.getter();
    }
    _parse(e) {
      let { ctx: r } = this._processInputParams(e);
      return this._def.getter()._parse({ data: r.data, path: r.path, parent: r });
    }
  };
We.create = (t, e) => new We({ getter: t, typeName: _.ZodLazy, ...b(e) });
var Le = class extends k {
  _parse(e) {
    if (e.data !== this._def.value) {
      let r = this._getOrReturnCtx(e);
      return (h(r, { received: r.data, code: f.invalid_literal, expected: this._def.value }), T);
    }
    return { status: "valid", value: e.data };
  }
  get value() {
    return this._def.value;
  }
};
Le.create = (t, e) => new Le({ value: t, typeName: _.ZodLiteral, ...b(e) });
function In(t, e) {
  return new Re({ values: t, typeName: _.ZodEnum, ...b(e) });
}
var Re = class t extends k {
  constructor() {
    (super(...arguments), wt.set(this, void 0));
  }
  _parse(e) {
    if (typeof e.data != "string") {
      let r = this._getOrReturnCtx(e),
        n = this._def.values;
      return (h(r, { expected: x.joinValues(n), received: r.parsedType, code: f.invalid_type }), T);
    }
    if (
      (rr(this, wt, "f") || xn(this, wt, new Set(this._def.values), "f"),
      !rr(this, wt, "f").has(e.data))
    ) {
      let r = this._getOrReturnCtx(e),
        n = this._def.values;
      return (h(r, { received: r.data, code: f.invalid_enum_value, options: n }), T);
    }
    return P(e.data);
  }
  get options() {
    return this._def.values;
  }
  get enum() {
    let e = {};
    for (let r of this._def.values) e[r] = r;
    return e;
  }
  get Values() {
    let e = {};
    for (let r of this._def.values) e[r] = r;
    return e;
  }
  get Enum() {
    let e = {};
    for (let r of this._def.values) e[r] = r;
    return e;
  }
  extract(e, r = this._def) {
    return t.create(e, { ...this._def, ...r });
  }
  exclude(e, r = this._def) {
    return t.create(
      this.options.filter((n) => !e.includes(n)),
      { ...this._def, ...r },
    );
  }
};
wt = new WeakMap();
Re.create = In;
var Ze = class extends k {
  constructor() {
    (super(...arguments), _t.set(this, void 0));
  }
  _parse(e) {
    let r = x.getValidEnumValues(this._def.values),
      n = this._getOrReturnCtx(e);
    if (n.parsedType !== p.string && n.parsedType !== p.number) {
      let s = x.objectValues(r);
      return (h(n, { expected: x.joinValues(s), received: n.parsedType, code: f.invalid_type }), T);
    }
    if (
      (rr(this, _t, "f") || xn(this, _t, new Set(x.getValidEnumValues(this._def.values)), "f"),
      !rr(this, _t, "f").has(e.data))
    ) {
      let s = x.objectValues(r);
      return (h(n, { received: n.data, code: f.invalid_enum_value, options: s }), T);
    }
    return P(e.data);
  }
  get enum() {
    return this._def.values;
  }
};
_t = new WeakMap();
Ze.create = (t, e) => new Ze({ values: t, typeName: _.ZodNativeEnum, ...b(e) });
var ve = class extends k {
  unwrap() {
    return this._def.type;
  }
  _parse(e) {
    let { ctx: r } = this._processInputParams(e);
    if (r.parsedType !== p.promise && r.common.async === !1)
      return (h(r, { code: f.invalid_type, expected: p.promise, received: r.parsedType }), T);
    let n = r.parsedType === p.promise ? r.data : Promise.resolve(r.data);
    return P(
      n.then((s) =>
        this._def.type.parseAsync(s, { path: r.path, errorMap: r.common.contextualErrorMap }),
      ),
    );
  }
};
ve.create = (t, e) => new ve({ type: t, typeName: _.ZodPromise, ...b(e) });
var j = class extends k {
  innerType() {
    return this._def.schema;
  }
  sourceType() {
    return this._def.schema._def.typeName === _.ZodEffects
      ? this._def.schema.sourceType()
      : this._def.schema;
  }
  _parse(e) {
    let { status: r, ctx: n } = this._processInputParams(e),
      s = this._def.effect || null,
      i = {
        addIssue: (a) => {
          (h(n, a), a.fatal ? r.abort() : r.dirty());
        },
        get path() {
          return n.path;
        },
      };
    if (((i.addIssue = i.addIssue.bind(i)), s.type === "preprocess")) {
      let a = s.transform(n.data, i);
      if (n.common.async)
        return Promise.resolve(a).then(async (o) => {
          if (r.value === "aborted") return T;
          let l = await this._def.schema._parseAsync({ data: o, path: n.path, parent: n });
          return l.status === "aborted"
            ? T
            : l.status === "dirty" || r.value === "dirty"
              ? Je(l.value)
              : l;
        });
      {
        if (r.value === "aborted") return T;
        let o = this._def.schema._parseSync({ data: a, path: n.path, parent: n });
        return o.status === "aborted"
          ? T
          : o.status === "dirty" || r.value === "dirty"
            ? Je(o.value)
            : o;
      }
    }
    if (s.type === "refinement") {
      let a = (o) => {
        let l = s.refinement(o, i);
        if (n.common.async) return Promise.resolve(l);
        if (l instanceof Promise)
          throw new Error(
            "Async refinement encountered during synchronous parse operation. Use .parseAsync instead.",
          );
        return o;
      };
      if (n.common.async === !1) {
        let o = this._def.schema._parseSync({ data: n.data, path: n.path, parent: n });
        return o.status === "aborted"
          ? T
          : (o.status === "dirty" && r.dirty(), a(o.value), { status: r.value, value: o.value });
      } else
        return this._def.schema
          ._parseAsync({ data: n.data, path: n.path, parent: n })
          .then((o) =>
            o.status === "aborted"
              ? T
              : (o.status === "dirty" && r.dirty(),
                a(o.value).then(() => ({ status: r.value, value: o.value }))),
          );
    }
    if (s.type === "transform")
      if (n.common.async === !1) {
        let a = this._def.schema._parseSync({ data: n.data, path: n.path, parent: n });
        if (!Ee(a)) return a;
        let o = s.transform(a.value, i);
        if (o instanceof Promise)
          throw new Error(
            "Asynchronous transform encountered during synchronous parse operation. Use .parseAsync instead.",
          );
        return { status: r.value, value: o };
      } else
        return this._def.schema
          ._parseAsync({ data: n.data, path: n.path, parent: n })
          .then((a) =>
            Ee(a)
              ? Promise.resolve(s.transform(a.value, i)).then((o) => ({
                  status: r.value,
                  value: o,
                }))
              : a,
          );
    x.assertNever(s);
  }
};
j.create = (t, e, r) => new j({ schema: t, typeName: _.ZodEffects, effect: e, ...b(r) });
j.createWithPreprocess = (t, e, r) =>
  new j({
    schema: e,
    effect: { type: "preprocess", transform: t },
    typeName: _.ZodEffects,
    ...b(r),
  });
var G = class extends k {
  _parse(e) {
    return this._getType(e) === p.undefined ? P(void 0) : this._def.innerType._parse(e);
  }
  unwrap() {
    return this._def.innerType;
  }
};
G.create = (t, e) => new G({ innerType: t, typeName: _.ZodOptional, ...b(e) });
var ae = class extends k {
  _parse(e) {
    return this._getType(e) === p.null ? P(null) : this._def.innerType._parse(e);
  }
  unwrap() {
    return this._def.innerType;
  }
};
ae.create = (t, e) => new ae({ innerType: t, typeName: _.ZodNullable, ...b(e) });
var Pe = class extends k {
  _parse(e) {
    let { ctx: r } = this._processInputParams(e),
      n = r.data;
    return (
      r.parsedType === p.undefined && (n = this._def.defaultValue()),
      this._def.innerType._parse({ data: n, path: r.path, parent: r })
    );
  }
  removeDefault() {
    return this._def.innerType;
  }
};
Pe.create = (t, e) =>
  new Pe({
    innerType: t,
    typeName: _.ZodDefault,
    defaultValue: typeof e.default == "function" ? e.default : () => e.default,
    ...b(e),
  });
var ze = class extends k {
  _parse(e) {
    let { ctx: r } = this._processInputParams(e),
      n = { ...r, common: { ...r.common, issues: [] } },
      s = this._def.innerType._parse({ data: n.data, path: n.path, parent: { ...n } });
    return Tt(s)
      ? s.then((i) => ({
          status: "valid",
          value:
            i.status === "valid"
              ? i.value
              : this._def.catchValue({
                  get error() {
                    return new $(n.common.issues);
                  },
                  input: n.data,
                }),
        }))
      : {
          status: "valid",
          value:
            s.status === "valid"
              ? s.value
              : this._def.catchValue({
                  get error() {
                    return new $(n.common.issues);
                  },
                  input: n.data,
                }),
        };
  }
  removeCatch() {
    return this._def.innerType;
  }
};
ze.create = (t, e) =>
  new ze({
    innerType: t,
    typeName: _.ZodCatch,
    catchValue: typeof e.catch == "function" ? e.catch : () => e.catch,
    ...b(e),
  });
var rt = class extends k {
  _parse(e) {
    if (this._getType(e) !== p.nan) {
      let n = this._getOrReturnCtx(e);
      return (h(n, { code: f.invalid_type, expected: p.nan, received: n.parsedType }), T);
    }
    return { status: "valid", value: e.data };
  }
};
rt.create = (t) => new rt({ typeName: _.ZodNaN, ...b(t) });
var ki = Symbol("zod_brand"),
  bt = class extends k {
    _parse(e) {
      let { ctx: r } = this._processInputParams(e),
        n = r.data;
      return this._def.type._parse({ data: n, path: r.path, parent: r });
    }
    unwrap() {
      return this._def.type;
    }
  },
  kt = class t extends k {
    _parse(e) {
      let { status: r, ctx: n } = this._processInputParams(e);
      if (n.common.async)
        return (async () => {
          let i = await this._def.in._parseAsync({ data: n.data, path: n.path, parent: n });
          return i.status === "aborted"
            ? T
            : i.status === "dirty"
              ? (r.dirty(), Je(i.value))
              : this._def.out._parseAsync({ data: i.value, path: n.path, parent: n });
        })();
      {
        let s = this._def.in._parseSync({ data: n.data, path: n.path, parent: n });
        return s.status === "aborted"
          ? T
          : s.status === "dirty"
            ? (r.dirty(), { status: "dirty", value: s.value })
            : this._def.out._parseSync({ data: s.value, path: n.path, parent: n });
      }
    }
    static create(e, r) {
      return new t({ in: e, out: r, typeName: _.ZodPipeline });
    }
  },
  Ve = class extends k {
    _parse(e) {
      let r = this._def.innerType._parse(e),
        n = (s) => (Ee(s) && (s.value = Object.freeze(s.value)), s);
      return Tt(r) ? r.then((s) => n(s)) : n(r);
    }
    unwrap() {
      return this._def.innerType;
    }
  };
Ve.create = (t, e) => new Ve({ innerType: t, typeName: _.ZodReadonly, ...b(e) });
function Tn(t, e) {
  let r = typeof t == "function" ? t(e) : typeof t == "string" ? { message: t } : t;
  return typeof r == "string" ? { message: r } : r;
}
function Dn(t, e = {}, r) {
  return t
    ? ge.create().superRefine((n, s) => {
        var i, a;
        let o = t(n);
        if (o instanceof Promise)
          return o.then((l) => {
            var u, d;
            if (!l) {
              let g = Tn(e, n),
                D =
                  (d = (u = g.fatal) !== null && u !== void 0 ? u : r) !== null && d !== void 0
                    ? d
                    : !0;
              s.addIssue({ code: "custom", ...g, fatal: D });
            }
          });
        if (!o) {
          let l = Tn(e, n),
            u =
              (a = (i = l.fatal) !== null && i !== void 0 ? i : r) !== null && a !== void 0
                ? a
                : !0;
          s.addIssue({ code: "custom", ...l, fatal: u });
        }
      })
    : ge.create();
}
var xi = { object: z.lazycreate },
  _;
(function (t) {
  ((t.ZodString = "ZodString"),
    (t.ZodNumber = "ZodNumber"),
    (t.ZodNaN = "ZodNaN"),
    (t.ZodBigInt = "ZodBigInt"),
    (t.ZodBoolean = "ZodBoolean"),
    (t.ZodDate = "ZodDate"),
    (t.ZodSymbol = "ZodSymbol"),
    (t.ZodUndefined = "ZodUndefined"),
    (t.ZodNull = "ZodNull"),
    (t.ZodAny = "ZodAny"),
    (t.ZodUnknown = "ZodUnknown"),
    (t.ZodNever = "ZodNever"),
    (t.ZodVoid = "ZodVoid"),
    (t.ZodArray = "ZodArray"),
    (t.ZodObject = "ZodObject"),
    (t.ZodUnion = "ZodUnion"),
    (t.ZodDiscriminatedUnion = "ZodDiscriminatedUnion"),
    (t.ZodIntersection = "ZodIntersection"),
    (t.ZodTuple = "ZodTuple"),
    (t.ZodRecord = "ZodRecord"),
    (t.ZodMap = "ZodMap"),
    (t.ZodSet = "ZodSet"),
    (t.ZodFunction = "ZodFunction"),
    (t.ZodLazy = "ZodLazy"),
    (t.ZodLiteral = "ZodLiteral"),
    (t.ZodEnum = "ZodEnum"),
    (t.ZodEffects = "ZodEffects"),
    (t.ZodNativeEnum = "ZodNativeEnum"),
    (t.ZodOptional = "ZodOptional"),
    (t.ZodNullable = "ZodNullable"),
    (t.ZodDefault = "ZodDefault"),
    (t.ZodCatch = "ZodCatch"),
    (t.ZodPromise = "ZodPromise"),
    (t.ZodBranded = "ZodBranded"),
    (t.ZodPipeline = "ZodPipeline"),
    (t.ZodReadonly = "ZodReadonly"));
})(_ || (_ = {}));
var Si = (t, e = { message: `Input not instance of ${t.name}` }) => Dn((r) => r instanceof t, e),
  Mn = ye.create,
  Nn = Oe.create,
  Ei = rt.create,
  Oi = Ie.create,
  Cn = De.create,
  Ii = Me.create,
  Di = Qe.create,
  Mi = Ne.create,
  Ni = Ce.create,
  Ci = ge.create,
  Ai = ce.create,
  Fi = K.create,
  Wi = Xe.create,
  Li = de.create,
  Ri = z.create,
  Zi = z.strictCreate,
  Pi = Ae.create,
  zi = nr.create,
  Vi = Fe.create,
  $i = ie.create,
  ji = sr.create,
  Ui = et.create,
  Hi = tt.create,
  Gi = ir.create,
  Yi = We.create,
  qi = Le.create,
  Bi = Re.create,
  Ji = Ze.create,
  Ki = ve.create,
  bn = j.create,
  Qi = G.create,
  Xi = ae.create,
  ea = j.createWithPreprocess,
  ta = kt.create,
  ra = () => Mn().optional(),
  na = () => Nn().optional(),
  sa = () => Cn().optional(),
  ia = {
    string: (t) => ye.create({ ...t, coerce: !0 }),
    number: (t) => Oe.create({ ...t, coerce: !0 }),
    boolean: (t) => De.create({ ...t, coerce: !0 }),
    bigint: (t) => Ie.create({ ...t, coerce: !0 }),
    date: (t) => Me.create({ ...t, coerce: !0 }),
  },
  aa = T,
  c = Object.freeze({
    __proto__: null,
    defaultErrorMap: Ke,
    setErrorMap: ei,
    getErrorMap: er,
    makeIssue: tr,
    EMPTY_PATH: ti,
    addIssueToContext: h,
    ParseStatus: R,
    INVALID: T,
    DIRTY: Je,
    OK: P,
    isAborted: Ir,
    isDirty: Dr,
    isValid: Ee,
    isAsync: Tt,
    get util() {
      return x;
    },
    get objectUtil() {
      return Or;
    },
    ZodParsedType: p,
    getParsedType: ue,
    ZodType: k,
    datetimeRegex: On,
    ZodString: ye,
    ZodNumber: Oe,
    ZodBigInt: Ie,
    ZodBoolean: De,
    ZodDate: Me,
    ZodSymbol: Qe,
    ZodUndefined: Ne,
    ZodNull: Ce,
    ZodAny: ge,
    ZodUnknown: ce,
    ZodNever: K,
    ZodVoid: Xe,
    ZodArray: de,
    ZodObject: z,
    ZodUnion: Ae,
    ZodDiscriminatedUnion: nr,
    ZodIntersection: Fe,
    ZodTuple: ie,
    ZodRecord: sr,
    ZodMap: et,
    ZodSet: tt,
    ZodFunction: ir,
    ZodLazy: We,
    ZodLiteral: Le,
    ZodEnum: Re,
    ZodNativeEnum: Ze,
    ZodPromise: ve,
    ZodEffects: j,
    ZodTransformer: j,
    ZodOptional: G,
    ZodNullable: ae,
    ZodDefault: Pe,
    ZodCatch: ze,
    ZodNaN: rt,
    BRAND: ki,
    ZodBranded: bt,
    ZodPipeline: kt,
    ZodReadonly: Ve,
    custom: Dn,
    Schema: k,
    ZodSchema: k,
    late: xi,
    get ZodFirstPartyTypeKind() {
      return _;
    },
    coerce: ia,
    any: Ci,
    array: Li,
    bigint: Oi,
    boolean: Cn,
    date: Ii,
    discriminatedUnion: zi,
    effect: bn,
    enum: Bi,
    function: Gi,
    instanceof: Si,
    intersection: Vi,
    lazy: Yi,
    literal: qi,
    map: Ui,
    nan: Ei,
    nativeEnum: Ji,
    never: Fi,
    null: Ni,
    nullable: Xi,
    number: Nn,
    object: Ri,
    oboolean: sa,
    onumber: na,
    optional: Qi,
    ostring: ra,
    pipeline: ta,
    preprocess: ea,
    promise: Ki,
    record: ji,
    set: Hi,
    strictObject: Zi,
    string: Mn,
    symbol: Di,
    transformer: bn,
    tuple: $i,
    undefined: Mi,
    union: Pi,
    unknown: Ai,
    void: Wi,
    NEVER: aa,
    ZodIssueCode: f,
    quotelessJson: Xs,
    ZodError: $,
  });
var oa, la, ua, ca;
((oa = new WeakMap()), (la = new WeakMap()), (ua = new WeakMap()));
async function xt(t, e = {}, r) {
  return window.__TAURI_INTERNALS__.invoke(t, e, r);
}
ca = new WeakMap();
var Nr;
(function (t) {
  ((t.WINDOW_RESIZED = "tauri://resize"),
    (t.WINDOW_MOVED = "tauri://move"),
    (t.WINDOW_CLOSE_REQUESTED = "tauri://close-requested"),
    (t.WINDOW_DESTROYED = "tauri://destroyed"),
    (t.WINDOW_FOCUS = "tauri://focus"),
    (t.WINDOW_BLUR = "tauri://blur"),
    (t.WINDOW_SCALE_FACTOR_CHANGED = "tauri://scale-change"),
    (t.WINDOW_THEME_CHANGED = "tauri://theme-changed"),
    (t.WINDOW_CREATED = "tauri://window-created"),
    (t.WEBVIEW_CREATED = "tauri://webview-created"),
    (t.DRAG_ENTER = "tauri://drag-enter"),
    (t.DRAG_OVER = "tauri://drag-over"),
    (t.DRAG_DROP = "tauri://drag-drop"),
    (t.DRAG_LEAVE = "tauri://drag-leave"));
})(Nr || (Nr = {}));
var An;
(function (t) {
  ((t[(t.Critical = 1)] = "Critical"), (t[(t.Informational = 2)] = "Informational"));
})(An || (An = {}));
var Fn;
(function (t) {
  ((t.None = "none"),
    (t.Normal = "normal"),
    (t.Indeterminate = "indeterminate"),
    (t.Paused = "paused"),
    (t.Error = "error"));
})(Fn || (Fn = {}));
var Wn;
(function (t) {
  ((t.AppearanceBased = "appearanceBased"),
    (t.Light = "light"),
    (t.Dark = "dark"),
    (t.MediumLight = "mediumLight"),
    (t.UltraDark = "ultraDark"),
    (t.Titlebar = "titlebar"),
    (t.Selection = "selection"),
    (t.Menu = "menu"),
    (t.Popover = "popover"),
    (t.Sidebar = "sidebar"),
    (t.HeaderView = "headerView"),
    (t.Sheet = "sheet"),
    (t.WindowBackground = "windowBackground"),
    (t.HudWindow = "hudWindow"),
    (t.FullScreenUI = "fullScreenUI"),
    (t.Tooltip = "tooltip"),
    (t.ContentBackground = "contentBackground"),
    (t.UnderWindowBackground = "underWindowBackground"),
    (t.UnderPageBackground = "underPageBackground"),
    (t.Mica = "mica"),
    (t.Blur = "blur"),
    (t.Acrylic = "acrylic"),
    (t.Tabbed = "tabbed"),
    (t.TabbedDark = "tabbedDark"),
    (t.TabbedLight = "tabbedLight"));
})(Wn || (Wn = {}));
var Ln;
(function (t) {
  ((t.FollowsWindowActiveState = "followsWindowActiveState"),
    (t.Active = "active"),
    (t.Inactive = "inactive"));
})(Ln || (Ln = {}));
var fe = class extends Error {},
  ar = class extends fe {
    constructor(e) {
      super(`Invalid DateTime: ${e.toMessage()}`);
    }
  },
  or = class extends fe {
    constructor(e) {
      super(`Invalid Interval: ${e.toMessage()}`);
    }
  },
  lr = class extends fe {
    constructor(e) {
      super(`Invalid Duration: ${e.toMessage()}`);
    }
  },
  Q = class extends fe {},
  nt = class extends fe {
    constructor(e) {
      super(`Invalid unit ${e}`);
    }
  },
  C = class extends fe {},
  X = class extends fe {
    constructor() {
      super("Zone is an abstract class");
    }
  };
var m = "numeric",
  ee = "short",
  U = "long",
  we = { year: m, month: m, day: m },
  St = { year: m, month: ee, day: m },
  Cr = { year: m, month: ee, day: m, weekday: ee },
  Et = { year: m, month: U, day: m },
  Ot = { year: m, month: U, day: m, weekday: U },
  It = { hour: m, minute: m },
  Dt = { hour: m, minute: m, second: m },
  Mt = { hour: m, minute: m, second: m, timeZoneName: ee },
  Nt = { hour: m, minute: m, second: m, timeZoneName: U },
  Ct = { hour: m, minute: m, hourCycle: "h23" },
  At = { hour: m, minute: m, second: m, hourCycle: "h23" },
  Ft = { hour: m, minute: m, second: m, hourCycle: "h23", timeZoneName: ee },
  Wt = { hour: m, minute: m, second: m, hourCycle: "h23", timeZoneName: U },
  Lt = { year: m, month: m, day: m, hour: m, minute: m },
  Rt = { year: m, month: m, day: m, hour: m, minute: m, second: m },
  Zt = { year: m, month: ee, day: m, hour: m, minute: m },
  Pt = { year: m, month: ee, day: m, hour: m, minute: m, second: m },
  Ar = { year: m, month: ee, day: m, weekday: ee, hour: m, minute: m },
  zt = { year: m, month: U, day: m, hour: m, minute: m, timeZoneName: ee },
  Vt = { year: m, month: U, day: m, hour: m, minute: m, second: m, timeZoneName: ee },
  $t = { year: m, month: U, day: m, weekday: U, hour: m, minute: m, timeZoneName: U },
  jt = { year: m, month: U, day: m, weekday: U, hour: m, minute: m, second: m, timeZoneName: U };
var V = class {
  get type() {
    throw new X();
  }
  get name() {
    throw new X();
  }
  get ianaName() {
    return this.name;
  }
  get isUniversal() {
    throw new X();
  }
  offsetName(e, r) {
    throw new X();
  }
  formatOffset(e, r) {
    throw new X();
  }
  offset(e) {
    throw new X();
  }
  equals(e) {
    throw new X();
  }
  get isValid() {
    throw new X();
  }
};
var Fr = null,
  _e = class t extends V {
    static get instance() {
      return (Fr === null && (Fr = new t()), Fr);
    }
    get type() {
      return "system";
    }
    get name() {
      return new Intl.DateTimeFormat().resolvedOptions().timeZone;
    }
    get isUniversal() {
      return !1;
    }
    offsetName(e, { format: r, locale: n }) {
      return cr(e, r, n);
    }
    formatOffset(e, r) {
      return Te(this.offset(e), r);
    }
    offset(e) {
      return -new Date(e).getTimezoneOffset();
    }
    equals(e) {
      return e.type === "system";
    }
    get isValid() {
      return !0;
    }
  };
var fr = {};
function da(t) {
  return (
    fr[t] ||
      (fr[t] = new Intl.DateTimeFormat("en-US", {
        hour12: !1,
        timeZone: t,
        year: "numeric",
        month: "2-digit",
        day: "2-digit",
        hour: "2-digit",
        minute: "2-digit",
        second: "2-digit",
        era: "short",
      })),
    fr[t]
  );
}
var fa = { year: 0, month: 1, day: 2, era: 3, hour: 4, minute: 5, second: 6 };
function ha(t, e) {
  let r = t.format(e).replace(/\u200E/g, ""),
    n = /(\d+)\/(\d+)\/(\d+) (AD|BC),? (\d+):(\d+):(\d+)/.exec(r),
    [, s, i, a, o, l, u, d] = n;
  return [a, s, i, o, l, u, d];
}
function ma(t, e) {
  let r = t.formatToParts(e),
    n = [];
  for (let s = 0; s < r.length; s++) {
    let { type: i, value: a } = r[s],
      o = fa[i];
    i === "era" ? (n[o] = a) : v(o) || (n[o] = parseInt(a, 10));
  }
  return n;
}
var dr = {},
  Z = class t extends V {
    static create(e) {
      return (dr[e] || (dr[e] = new t(e)), dr[e]);
    }
    static resetCache() {
      ((dr = {}), (fr = {}));
    }
    static isValidSpecifier(e) {
      return this.isValidZone(e);
    }
    static isValidZone(e) {
      if (!e) return !1;
      try {
        return (new Intl.DateTimeFormat("en-US", { timeZone: e }).format(), !0);
      } catch {
        return !1;
      }
    }
    constructor(e) {
      (super(), (this.zoneName = e), (this.valid = t.isValidZone(e)));
    }
    get type() {
      return "iana";
    }
    get name() {
      return this.zoneName;
    }
    get isUniversal() {
      return !1;
    }
    offsetName(e, { format: r, locale: n }) {
      return cr(e, r, n, this.name);
    }
    formatOffset(e, r) {
      return Te(this.offset(e), r);
    }
    offset(e) {
      let r = new Date(e);
      if (isNaN(r)) return NaN;
      let n = da(this.name),
        [s, i, a, o, l, u, d] = n.formatToParts ? ma(n, r) : ha(n, r);
      o === "BC" && (s = -Math.abs(s) + 1);
      let D = st({
          year: s,
          month: i,
          day: a,
          hour: l === 24 ? 0 : l,
          minute: u,
          second: d,
          millisecond: 0,
        }),
        w = +r,
        A = w % 1e3;
      return ((w -= A >= 0 ? A : 1e3 + A), (D - w) / (60 * 1e3));
    }
    equals(e) {
      return e.type === "iana" && e.name === this.name;
    }
    get isValid() {
      return this.valid;
    }
  };
var Zn = {};
function pa(t, e = {}) {
  let r = JSON.stringify([t, e]),
    n = Zn[r];
  return (n || ((n = new Intl.ListFormat(t, e)), (Zn[r] = n)), n);
}
var Wr = {};
function Lr(t, e = {}) {
  let r = JSON.stringify([t, e]),
    n = Wr[r];
  return (n || ((n = new Intl.DateTimeFormat(t, e)), (Wr[r] = n)), n);
}
var Rr = {};
function ya(t, e = {}) {
  let r = JSON.stringify([t, e]),
    n = Rr[r];
  return (n || ((n = new Intl.NumberFormat(t, e)), (Rr[r] = n)), n);
}
var Zr = {};
function ga(t, e = {}) {
  let { base: r, ...n } = e,
    s = JSON.stringify([t, n]),
    i = Zr[s];
  return (i || ((i = new Intl.RelativeTimeFormat(t, e)), (Zr[s] = i)), i);
}
var Ut = null;
function va() {
  return Ut || ((Ut = new Intl.DateTimeFormat().resolvedOptions().locale), Ut);
}
var Pn = {};
function wa(t) {
  let e = Pn[t];
  if (!e) {
    let r = new Intl.Locale(t);
    ((e = "getWeekInfo" in r ? r.getWeekInfo() : r.weekInfo), (Pn[t] = e));
  }
  return e;
}
function _a(t) {
  let e = t.indexOf("-x-");
  e !== -1 && (t = t.substring(0, e));
  let r = t.indexOf("-u-");
  if (r === -1) return [t];
  {
    let n, s;
    try {
      ((n = Lr(t).resolvedOptions()), (s = t));
    } catch {
      let l = t.substring(0, r);
      ((n = Lr(l).resolvedOptions()), (s = l));
    }
    let { numberingSystem: i, calendar: a } = n;
    return [s, i, a];
  }
}
function Ta(t, e, r) {
  return (
    (r || e) && (t.includes("-u-") || (t += "-u"), r && (t += `-ca-${r}`), e && (t += `-nu-${e}`)),
    t
  );
}
function ba(t) {
  let e = [];
  for (let r = 1; r <= 12; r++) {
    let n = I.utc(2009, r, 1);
    e.push(t(n));
  }
  return e;
}
function ka(t) {
  let e = [];
  for (let r = 1; r <= 7; r++) {
    let n = I.utc(2016, 11, 13 + r);
    e.push(t(n));
  }
  return e;
}
function hr(t, e, r, n) {
  let s = t.listingMode();
  return s === "error" ? null : s === "en" ? r(e) : n(e);
}
function xa(t) {
  return t.numberingSystem && t.numberingSystem !== "latn"
    ? !1
    : t.numberingSystem === "latn" ||
        !t.locale ||
        t.locale.startsWith("en") ||
        new Intl.DateTimeFormat(t.intl).resolvedOptions().numberingSystem === "latn";
}
var Pr = class {
    constructor(e, r, n) {
      ((this.padTo = n.padTo || 0), (this.floor = n.floor || !1));
      let { padTo: s, floor: i, ...a } = n;
      if (!r || Object.keys(a).length > 0) {
        let o = { useGrouping: !1, ...n };
        (n.padTo > 0 && (o.minimumIntegerDigits = n.padTo), (this.inf = ya(e, o)));
      }
    }
    format(e) {
      if (this.inf) {
        let r = this.floor ? Math.floor(e) : e;
        return this.inf.format(r);
      } else {
        let r = this.floor ? Math.floor(e) : it(e, 3);
        return M(r, this.padTo);
      }
    }
  },
  zr = class {
    constructor(e, r, n) {
      ((this.opts = n), (this.originalZone = void 0));
      let s;
      if (this.opts.timeZone) this.dt = e;
      else if (e.zone.type === "fixed") {
        let a = -1 * (e.offset / 60),
          o = a >= 0 ? `Etc/GMT+${a}` : `Etc/GMT${a}`;
        e.offset !== 0 && Z.create(o).valid
          ? ((s = o), (this.dt = e))
          : ((s = "UTC"),
            (this.dt = e.offset === 0 ? e : e.setZone("UTC").plus({ minutes: e.offset })),
            (this.originalZone = e.zone));
      } else
        e.zone.type === "system"
          ? (this.dt = e)
          : e.zone.type === "iana"
            ? ((this.dt = e), (s = e.zone.name))
            : ((s = "UTC"),
              (this.dt = e.setZone("UTC").plus({ minutes: e.offset })),
              (this.originalZone = e.zone));
      let i = { ...this.opts };
      ((i.timeZone = i.timeZone || s), (this.dtf = Lr(r, i)));
    }
    format() {
      return this.originalZone
        ? this.formatToParts()
            .map(({ value: e }) => e)
            .join("")
        : this.dtf.format(this.dt.toJSDate());
    }
    formatToParts() {
      let e = this.dtf.formatToParts(this.dt.toJSDate());
      return this.originalZone
        ? e.map((r) => {
            if (r.type === "timeZoneName") {
              let n = this.originalZone.offsetName(this.dt.ts, {
                locale: this.dt.locale,
                format: this.opts.timeZoneName,
              });
              return { ...r, value: n };
            } else return r;
          })
        : e;
    }
    resolvedOptions() {
      return this.dtf.resolvedOptions();
    }
  },
  Vr = class {
    constructor(e, r, n) {
      ((this.opts = { style: "long", ...n }), !r && mr() && (this.rtf = ga(e, n)));
    }
    format(e, r) {
      return this.rtf
        ? this.rtf.format(e, r)
        : zn(r, e, this.opts.numeric, this.opts.style !== "long");
    }
    formatToParts(e, r) {
      return this.rtf ? this.rtf.formatToParts(e, r) : [];
    }
  },
  Sa = { firstDay: 1, minimalDays: 4, weekend: [6, 7] },
  O = class t {
    static fromOpts(e) {
      return t.create(e.locale, e.numberingSystem, e.outputCalendar, e.weekSettings, e.defaultToEN);
    }
    static create(e, r, n, s, i = !1) {
      let a = e || S.defaultLocale,
        o = a || (i ? "en-US" : va()),
        l = r || S.defaultNumberingSystem,
        u = n || S.defaultOutputCalendar,
        d = Ht(s) || S.defaultWeekSettings;
      return new t(o, l, u, d, a);
    }
    static resetCache() {
      ((Ut = null), (Wr = {}), (Rr = {}), (Zr = {}));
    }
    static fromObject({ locale: e, numberingSystem: r, outputCalendar: n, weekSettings: s } = {}) {
      return t.create(e, r, n, s);
    }
    constructor(e, r, n, s, i) {
      let [a, o, l] = _a(e);
      ((this.locale = a),
        (this.numberingSystem = r || o || null),
        (this.outputCalendar = n || l || null),
        (this.weekSettings = s),
        (this.intl = Ta(this.locale, this.numberingSystem, this.outputCalendar)),
        (this.weekdaysCache = { format: {}, standalone: {} }),
        (this.monthsCache = { format: {}, standalone: {} }),
        (this.meridiemCache = null),
        (this.eraCache = {}),
        (this.specifiedLocale = i),
        (this.fastNumbersCached = null));
    }
    get fastNumbers() {
      return (
        this.fastNumbersCached == null && (this.fastNumbersCached = xa(this)),
        this.fastNumbersCached
      );
    }
    listingMode() {
      let e = this.isEnglish(),
        r =
          (this.numberingSystem === null || this.numberingSystem === "latn") &&
          (this.outputCalendar === null || this.outputCalendar === "gregory");
      return e && r ? "en" : "intl";
    }
    clone(e) {
      return !e || Object.getOwnPropertyNames(e).length === 0
        ? this
        : t.create(
            e.locale || this.specifiedLocale,
            e.numberingSystem || this.numberingSystem,
            e.outputCalendar || this.outputCalendar,
            Ht(e.weekSettings) || this.weekSettings,
            e.defaultToEN || !1,
          );
    }
    redefaultToEN(e = {}) {
      return this.clone({ ...e, defaultToEN: !0 });
    }
    redefaultToSystem(e = {}) {
      return this.clone({ ...e, defaultToEN: !1 });
    }
    months(e, r = !1) {
      return hr(this, e, $r, () => {
        let n = r ? { month: e, day: "numeric" } : { month: e },
          s = r ? "format" : "standalone";
        return (
          this.monthsCache[s][e] ||
            (this.monthsCache[s][e] = ba((i) => this.extract(i, n, "month"))),
          this.monthsCache[s][e]
        );
      });
    }
    weekdays(e, r = !1) {
      return hr(this, e, jr, () => {
        let n = r ? { weekday: e, year: "numeric", month: "long", day: "numeric" } : { weekday: e },
          s = r ? "format" : "standalone";
        return (
          this.weekdaysCache[s][e] ||
            (this.weekdaysCache[s][e] = ka((i) => this.extract(i, n, "weekday"))),
          this.weekdaysCache[s][e]
        );
      });
    }
    meridiems() {
      return hr(
        this,
        void 0,
        () => Ur,
        () => {
          if (!this.meridiemCache) {
            let e = { hour: "numeric", hourCycle: "h12" };
            this.meridiemCache = [I.utc(2016, 11, 13, 9), I.utc(2016, 11, 13, 19)].map((r) =>
              this.extract(r, e, "dayperiod"),
            );
          }
          return this.meridiemCache;
        },
      );
    }
    eras(e) {
      return hr(this, e, Hr, () => {
        let r = { era: e };
        return (
          this.eraCache[e] ||
            (this.eraCache[e] = [I.utc(-40, 1, 1), I.utc(2017, 1, 1)].map((n) =>
              this.extract(n, r, "era"),
            )),
          this.eraCache[e]
        );
      });
    }
    extract(e, r, n) {
      let s = this.dtFormatter(e, r),
        i = s.formatToParts(),
        a = i.find((o) => o.type.toLowerCase() === n);
      return a ? a.value : null;
    }
    numberFormatter(e = {}) {
      return new Pr(this.intl, e.forceSimple || this.fastNumbers, e);
    }
    dtFormatter(e, r = {}) {
      return new zr(e, this.intl, r);
    }
    relFormatter(e = {}) {
      return new Vr(this.intl, this.isEnglish(), e);
    }
    listFormatter(e = {}) {
      return pa(this.intl, e);
    }
    isEnglish() {
      return (
        this.locale === "en" ||
        this.locale.toLowerCase() === "en-us" ||
        new Intl.DateTimeFormat(this.intl).resolvedOptions().locale.startsWith("en-us")
      );
    }
    getWeekSettings() {
      return this.weekSettings ? this.weekSettings : pr() ? wa(this.locale) : Sa;
    }
    getStartOfWeek() {
      return this.getWeekSettings().firstDay;
    }
    getMinDaysInFirstWeek() {
      return this.getWeekSettings().minimalDays;
    }
    getWeekendDays() {
      return this.getWeekSettings().weekend;
    }
    equals(e) {
      return (
        this.locale === e.locale &&
        this.numberingSystem === e.numberingSystem &&
        this.outputCalendar === e.outputCalendar
      );
    }
  };
var Yr = null,
  F = class t extends V {
    static get utcInstance() {
      return (Yr === null && (Yr = new t(0)), Yr);
    }
    static instance(e) {
      return e === 0 ? t.utcInstance : new t(e);
    }
    static parseSpecifier(e) {
      if (e) {
        let r = e.match(/^utc(?:([+-]\d{1,2})(?::(\d{2}))?)?$/i);
        if (r) return new t($e(r[1], r[2]));
      }
      return null;
    }
    constructor(e) {
      (super(), (this.fixed = e));
    }
    get type() {
      return "fixed";
    }
    get name() {
      return this.fixed === 0 ? "UTC" : `UTC${Te(this.fixed, "narrow")}`;
    }
    get ianaName() {
      return this.fixed === 0 ? "Etc/UTC" : `Etc/GMT${Te(-this.fixed, "narrow")}`;
    }
    offsetName() {
      return this.name;
    }
    formatOffset(e, r) {
      return Te(this.fixed, r);
    }
    get isUniversal() {
      return !0;
    }
    offset() {
      return this.fixed;
    }
    equals(e) {
      return e.type === "fixed" && e.fixed === this.fixed;
    }
    get isValid() {
      return !0;
    }
  };
var at = class extends V {
  constructor(e) {
    (super(), (this.zoneName = e));
  }
  get type() {
    return "invalid";
  }
  get name() {
    return this.zoneName;
  }
  get isUniversal() {
    return !1;
  }
  offsetName() {
    return null;
  }
  formatOffset() {
    return "";
  }
  offset() {
    return NaN;
  }
  equals() {
    return !1;
  }
  get isValid() {
    return !1;
  }
};
function te(t, e) {
  let r;
  if (v(t) || t === null) return e;
  if (t instanceof V) return t;
  if (Vn(t)) {
    let n = t.toLowerCase();
    return n === "default"
      ? e
      : n === "local" || n === "system"
        ? _e.instance
        : n === "utc" || n === "gmt"
          ? F.utcInstance
          : F.parseSpecifier(n) || Z.create(t);
  } else
    return oe(t)
      ? F.instance(t)
      : typeof t == "object" && "offset" in t && typeof t.offset == "function"
        ? t
        : new at(t);
}
var $n = () => Date.now(),
  jn = "system",
  Un = null,
  Hn = null,
  Gn = null,
  Yn = 60,
  qn,
  Bn = null,
  S = class {
    static get now() {
      return $n;
    }
    static set now(e) {
      $n = e;
    }
    static set defaultZone(e) {
      jn = e;
    }
    static get defaultZone() {
      return te(jn, _e.instance);
    }
    static get defaultLocale() {
      return Un;
    }
    static set defaultLocale(e) {
      Un = e;
    }
    static get defaultNumberingSystem() {
      return Hn;
    }
    static set defaultNumberingSystem(e) {
      Hn = e;
    }
    static get defaultOutputCalendar() {
      return Gn;
    }
    static set defaultOutputCalendar(e) {
      Gn = e;
    }
    static get defaultWeekSettings() {
      return Bn;
    }
    static set defaultWeekSettings(e) {
      Bn = Ht(e);
    }
    static get twoDigitCutoffYear() {
      return Yn;
    }
    static set twoDigitCutoffYear(e) {
      Yn = e % 100;
    }
    static get throwOnInvalid() {
      return qn;
    }
    static set throwOnInvalid(e) {
      qn = e;
    }
    static resetCaches() {
      (O.resetCache(), Z.resetCache());
    }
  };
var W = class {
  constructor(e, r) {
    ((this.reason = e), (this.explanation = r));
  }
  toMessage() {
    return this.explanation ? `${this.reason}: ${this.explanation}` : this.reason;
  }
};
var Jn = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334],
  Kn = [0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335];
function q(t, e) {
  return new W(
    "unit out of range",
    `you specified ${e} (of type ${typeof e}) as a ${t}, which is invalid`,
  );
}
function yr(t, e, r) {
  let n = new Date(Date.UTC(t, e - 1, r));
  t < 100 && t >= 0 && n.setUTCFullYear(n.getUTCFullYear() - 1900);
  let s = n.getUTCDay();
  return s === 0 ? 7 : s;
}
function Qn(t, e, r) {
  return r + (Ue(t) ? Kn : Jn)[e - 1];
}
function Xn(t, e) {
  let r = Ue(t) ? Kn : Jn,
    n = r.findIndex((i) => i < e),
    s = e - r[n];
  return { month: n + 1, day: s };
}
function gr(t, e) {
  return ((t - e + 7) % 7) + 1;
}
function Gt(t, e = 4, r = 1) {
  let { year: n, month: s, day: i } = t,
    a = Qn(n, s, i),
    o = gr(yr(n, s, i), r),
    l = Math.floor((a - o + 14 - e) / 7),
    u;
  return (
    l < 1 ? ((u = n - 1), (l = je(u, e, r))) : l > je(n, e, r) ? ((u = n + 1), (l = 1)) : (u = n),
    { weekYear: u, weekNumber: l, weekday: o, ...qt(t) }
  );
}
function qr(t, e = 4, r = 1) {
  let { weekYear: n, weekNumber: s, weekday: i } = t,
    a = gr(yr(n, 1, e), r),
    o = be(n),
    l = s * 7 + i - a - 7 + e,
    u;
  l < 1 ? ((u = n - 1), (l += be(u))) : l > o ? ((u = n + 1), (l -= be(n))) : (u = n);
  let { month: d, day: g } = Xn(u, l);
  return { year: u, month: d, day: g, ...qt(t) };
}
function vr(t) {
  let { year: e, month: r, day: n } = t,
    s = Qn(e, r, n);
  return { year: e, ordinal: s, ...qt(t) };
}
function Br(t) {
  let { year: e, ordinal: r } = t,
    { month: n, day: s } = Xn(e, r);
  return { year: e, month: n, day: s, ...qt(t) };
}
function Jr(t, e) {
  if (!v(t.localWeekday) || !v(t.localWeekNumber) || !v(t.localWeekYear)) {
    if (!v(t.weekday) || !v(t.weekNumber) || !v(t.weekYear))
      throw new Q("Cannot mix locale-based week fields with ISO-based week fields");
    return (
      v(t.localWeekday) || (t.weekday = t.localWeekday),
      v(t.localWeekNumber) || (t.weekNumber = t.localWeekNumber),
      v(t.localWeekYear) || (t.weekYear = t.localWeekYear),
      delete t.localWeekday,
      delete t.localWeekNumber,
      delete t.localWeekYear,
      { minDaysInFirstWeek: e.getMinDaysInFirstWeek(), startOfWeek: e.getStartOfWeek() }
    );
  } else return { minDaysInFirstWeek: 4, startOfWeek: 1 };
}
function es(t, e = 4, r = 1) {
  let n = Yt(t.weekYear),
    s = H(t.weekNumber, 1, je(t.weekYear, e, r)),
    i = H(t.weekday, 1, 7);
  return n
    ? s
      ? i
        ? !1
        : q("weekday", t.weekday)
      : q("week", t.weekNumber)
    : q("weekYear", t.weekYear);
}
function ts(t) {
  let e = Yt(t.year),
    r = H(t.ordinal, 1, be(t.year));
  return e ? (r ? !1 : q("ordinal", t.ordinal)) : q("year", t.year);
}
function Kr(t) {
  let e = Yt(t.year),
    r = H(t.month, 1, 12),
    n = H(t.day, 1, ot(t.year, t.month));
  return e ? (r ? (n ? !1 : q("day", t.day)) : q("month", t.month)) : q("year", t.year);
}
function Qr(t) {
  let { hour: e, minute: r, second: n, millisecond: s } = t,
    i = H(e, 0, 23) || (e === 24 && r === 0 && n === 0 && s === 0),
    a = H(r, 0, 59),
    o = H(n, 0, 59),
    l = H(s, 0, 999);
  return i
    ? a
      ? o
        ? l
          ? !1
          : q("millisecond", s)
        : q("second", n)
      : q("minute", r)
    : q("hour", e);
}
function v(t) {
  return typeof t > "u";
}
function oe(t) {
  return typeof t == "number";
}
function Yt(t) {
  return typeof t == "number" && t % 1 === 0;
}
function Vn(t) {
  return typeof t == "string";
}
function ns(t) {
  return Object.prototype.toString.call(t) === "[object Date]";
}
function mr() {
  try {
    return typeof Intl < "u" && !!Intl.RelativeTimeFormat;
  } catch {
    return !1;
  }
}
function pr() {
  try {
    return (
      typeof Intl < "u" &&
      !!Intl.Locale &&
      ("weekInfo" in Intl.Locale.prototype || "getWeekInfo" in Intl.Locale.prototype)
    );
  } catch {
    return !1;
  }
}
function ss(t) {
  return Array.isArray(t) ? t : [t];
}
function Xr(t, e, r) {
  if (t.length !== 0)
    return t.reduce((n, s) => {
      let i = [e(s), s];
      return n && r(n[0], i[0]) === n[0] ? n : i;
    }, null)[1];
}
function is(t, e) {
  return e.reduce((r, n) => ((r[n] = t[n]), r), {});
}
function ke(t, e) {
  return Object.prototype.hasOwnProperty.call(t, e);
}
function Ht(t) {
  if (t == null) return null;
  if (typeof t != "object") throw new C("Week settings must be an object");
  if (
    !H(t.firstDay, 1, 7) ||
    !H(t.minimalDays, 1, 7) ||
    !Array.isArray(t.weekend) ||
    t.weekend.some((e) => !H(e, 1, 7))
  )
    throw new C("Invalid week settings");
  return { firstDay: t.firstDay, minimalDays: t.minimalDays, weekend: Array.from(t.weekend) };
}
function H(t, e, r) {
  return Yt(t) && t >= e && t <= r;
}
function Ea(t, e) {
  return t - e * Math.floor(t / e);
}
function M(t, e = 2) {
  let r = t < 0,
    n;
  return (r ? (n = "-" + ("" + -t).padStart(e, "0")) : (n = ("" + t).padStart(e, "0")), n);
}
function he(t) {
  if (!(v(t) || t === null || t === "")) return parseInt(t, 10);
}
function xe(t) {
  if (!(v(t) || t === null || t === "")) return parseFloat(t);
}
function Bt(t) {
  if (!(v(t) || t === null || t === "")) {
    let e = parseFloat("0." + t) * 1e3;
    return Math.floor(e);
  }
}
function it(t, e, r = !1) {
  let n = 10 ** e;
  return (r ? Math.trunc : Math.round)(t * n) / n;
}
function Ue(t) {
  return t % 4 === 0 && (t % 100 !== 0 || t % 400 === 0);
}
function be(t) {
  return Ue(t) ? 366 : 365;
}
function ot(t, e) {
  let r = Ea(e - 1, 12) + 1,
    n = t + (e - r) / 12;
  return r === 2 ? (Ue(n) ? 29 : 28) : [31, null, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][r - 1];
}
function st(t) {
  let e = Date.UTC(t.year, t.month - 1, t.day, t.hour, t.minute, t.second, t.millisecond);
  return (
    t.year < 100 &&
      t.year >= 0 &&
      ((e = new Date(e)), e.setUTCFullYear(t.year, t.month - 1, t.day)),
    +e
  );
}
function rs(t, e, r) {
  return -gr(yr(t, 1, e), r) + e - 1;
}
function je(t, e = 4, r = 1) {
  let n = rs(t, e, r),
    s = rs(t + 1, e, r);
  return (be(t) - n + s) / 7;
}
function Jt(t) {
  return t > 99 ? t : t > S.twoDigitCutoffYear ? 1900 + t : 2e3 + t;
}
function cr(t, e, r, n = null) {
  let s = new Date(t),
    i = {
      hourCycle: "h23",
      year: "numeric",
      month: "2-digit",
      day: "2-digit",
      hour: "2-digit",
      minute: "2-digit",
    };
  n && (i.timeZone = n);
  let a = { timeZoneName: e, ...i },
    o = new Intl.DateTimeFormat(r, a)
      .formatToParts(s)
      .find((l) => l.type.toLowerCase() === "timezonename");
  return o ? o.value : null;
}
function $e(t, e) {
  let r = parseInt(t, 10);
  Number.isNaN(r) && (r = 0);
  let n = parseInt(e, 10) || 0,
    s = r < 0 || Object.is(r, -0) ? -n : n;
  return r * 60 + s;
}
function en(t) {
  let e = Number(t);
  if (typeof t == "boolean" || t === "" || Number.isNaN(e)) throw new C(`Invalid unit value ${t}`);
  return e;
}
function lt(t, e) {
  let r = {};
  for (let n in t)
    if (ke(t, n)) {
      let s = t[n];
      if (s == null) continue;
      r[e(n)] = en(s);
    }
  return r;
}
function Te(t, e) {
  let r = Math.trunc(Math.abs(t / 60)),
    n = Math.trunc(Math.abs(t % 60)),
    s = t >= 0 ? "+" : "-";
  switch (e) {
    case "short":
      return `${s}${M(r, 2)}:${M(n, 2)}`;
    case "narrow":
      return `${s}${r}${n > 0 ? `:${n}` : ""}`;
    case "techie":
      return `${s}${M(r, 2)}${M(n, 2)}`;
    default:
      throw new RangeError(`Value format ${e} is out of range for property format`);
  }
}
function qt(t) {
  return is(t, ["hour", "minute", "second", "millisecond"]);
}
var Oa = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ],
  tn = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
  Ia = ["J", "F", "M", "A", "M", "J", "J", "A", "S", "O", "N", "D"];
function $r(t) {
  switch (t) {
    case "narrow":
      return [...Ia];
    case "short":
      return [...tn];
    case "long":
      return [...Oa];
    case "numeric":
      return ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"];
    case "2-digit":
      return ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"];
    default:
      return null;
  }
}
var rn = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"],
  nn = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
  Da = ["M", "T", "W", "T", "F", "S", "S"];
function jr(t) {
  switch (t) {
    case "narrow":
      return [...Da];
    case "short":
      return [...nn];
    case "long":
      return [...rn];
    case "numeric":
      return ["1", "2", "3", "4", "5", "6", "7"];
    default:
      return null;
  }
}
var Ur = ["AM", "PM"],
  Ma = ["Before Christ", "Anno Domini"],
  Na = ["BC", "AD"],
  Ca = ["B", "A"];
function Hr(t) {
  switch (t) {
    case "narrow":
      return [...Ca];
    case "short":
      return [...Na];
    case "long":
      return [...Ma];
    default:
      return null;
  }
}
function as(t) {
  return Ur[t.hour < 12 ? 0 : 1];
}
function os(t, e) {
  return jr(e)[t.weekday - 1];
}
function ls(t, e) {
  return $r(e)[t.month - 1];
}
function us(t, e) {
  return Hr(e)[t.year < 0 ? 0 : 1];
}
function zn(t, e, r = "always", n = !1) {
  let s = {
      years: ["year", "yr."],
      quarters: ["quarter", "qtr."],
      months: ["month", "mo."],
      weeks: ["week", "wk."],
      days: ["day", "day", "days"],
      hours: ["hour", "hr."],
      minutes: ["minute", "min."],
      seconds: ["second", "sec."],
    },
    i = ["hours", "minutes", "seconds"].indexOf(t) === -1;
  if (r === "auto" && i) {
    let g = t === "days";
    switch (e) {
      case 1:
        return g ? "tomorrow" : `next ${s[t][0]}`;
      case -1:
        return g ? "yesterday" : `last ${s[t][0]}`;
      case 0:
        return g ? "today" : `this ${s[t][0]}`;
      default:
    }
  }
  let a = Object.is(e, -0) || e < 0,
    o = Math.abs(e),
    l = o === 1,
    u = s[t],
    d = n ? (l ? u[1] : u[2] || u[1]) : l ? s[t][0] : t;
  return a ? `${o} ${d} ago` : `in ${o} ${d}`;
}
function cs(t, e) {
  let r = "";
  for (let n of t) n.literal ? (r += n.val) : (r += e(n.val));
  return r;
}
var Aa = {
    D: we,
    DD: St,
    DDD: Et,
    DDDD: Ot,
    t: It,
    tt: Dt,
    ttt: Mt,
    tttt: Nt,
    T: Ct,
    TT: At,
    TTT: Ft,
    TTTT: Wt,
    f: Lt,
    ff: Zt,
    fff: zt,
    ffff: $t,
    F: Rt,
    FF: Pt,
    FFF: Vt,
    FFFF: jt,
  },
  L = class t {
    static create(e, r = {}) {
      return new t(e, r);
    }
    static parseFormat(e) {
      let r = null,
        n = "",
        s = !1,
        i = [];
      for (let a = 0; a < e.length; a++) {
        let o = e.charAt(a);
        o === "'"
          ? (n.length > 0 && i.push({ literal: s || /^\s+$/.test(n), val: n }),
            (r = null),
            (n = ""),
            (s = !s))
          : s || o === r
            ? (n += o)
            : (n.length > 0 && i.push({ literal: /^\s+$/.test(n), val: n }), (n = o), (r = o));
      }
      return (n.length > 0 && i.push({ literal: s || /^\s+$/.test(n), val: n }), i);
    }
    static macroTokenToFormatOpts(e) {
      return Aa[e];
    }
    constructor(e, r) {
      ((this.opts = r), (this.loc = e), (this.systemLoc = null));
    }
    formatWithSystemDefault(e, r) {
      return (
        this.systemLoc === null && (this.systemLoc = this.loc.redefaultToSystem()),
        this.systemLoc.dtFormatter(e, { ...this.opts, ...r }).format()
      );
    }
    dtFormatter(e, r = {}) {
      return this.loc.dtFormatter(e, { ...this.opts, ...r });
    }
    formatDateTime(e, r) {
      return this.dtFormatter(e, r).format();
    }
    formatDateTimeParts(e, r) {
      return this.dtFormatter(e, r).formatToParts();
    }
    formatInterval(e, r) {
      return this.dtFormatter(e.start, r).dtf.formatRange(e.start.toJSDate(), e.end.toJSDate());
    }
    resolvedOptions(e, r) {
      return this.dtFormatter(e, r).resolvedOptions();
    }
    num(e, r = 0) {
      if (this.opts.forceSimple) return M(e, r);
      let n = { ...this.opts };
      return (r > 0 && (n.padTo = r), this.loc.numberFormatter(n).format(e));
    }
    formatDateTimeFromString(e, r) {
      let n = this.loc.listingMode() === "en",
        s = this.loc.outputCalendar && this.loc.outputCalendar !== "gregory",
        i = (w, A) => this.loc.extract(e, w, A),
        a = (w) =>
          e.isOffsetFixed && e.offset === 0 && w.allowZ
            ? "Z"
            : e.isValid
              ? e.zone.formatOffset(e.ts, w.format)
              : "",
        o = () => (n ? as(e) : i({ hour: "numeric", hourCycle: "h12" }, "dayperiod")),
        l = (w, A) => (n ? ls(e, w) : i(A ? { month: w } : { month: w, day: "numeric" }, "month")),
        u = (w, A) =>
          n
            ? os(e, w)
            : i(A ? { weekday: w } : { weekday: w, month: "long", day: "numeric" }, "weekday"),
        d = (w) => {
          let A = t.macroTokenToFormatOpts(w);
          return A ? this.formatWithSystemDefault(e, A) : w;
        },
        g = (w) => (n ? us(e, w) : i({ era: w }, "era")),
        D = (w) => {
          switch (w) {
            case "S":
              return this.num(e.millisecond);
            case "u":
            case "SSS":
              return this.num(e.millisecond, 3);
            case "s":
              return this.num(e.second);
            case "ss":
              return this.num(e.second, 2);
            case "uu":
              return this.num(Math.floor(e.millisecond / 10), 2);
            case "uuu":
              return this.num(Math.floor(e.millisecond / 100));
            case "m":
              return this.num(e.minute);
            case "mm":
              return this.num(e.minute, 2);
            case "h":
              return this.num(e.hour % 12 === 0 ? 12 : e.hour % 12);
            case "hh":
              return this.num(e.hour % 12 === 0 ? 12 : e.hour % 12, 2);
            case "H":
              return this.num(e.hour);
            case "HH":
              return this.num(e.hour, 2);
            case "Z":
              return a({ format: "narrow", allowZ: this.opts.allowZ });
            case "ZZ":
              return a({ format: "short", allowZ: this.opts.allowZ });
            case "ZZZ":
              return a({ format: "techie", allowZ: this.opts.allowZ });
            case "ZZZZ":
              return e.zone.offsetName(e.ts, { format: "short", locale: this.loc.locale });
            case "ZZZZZ":
              return e.zone.offsetName(e.ts, { format: "long", locale: this.loc.locale });
            case "z":
              return e.zoneName;
            case "a":
              return o();
            case "d":
              return s ? i({ day: "numeric" }, "day") : this.num(e.day);
            case "dd":
              return s ? i({ day: "2-digit" }, "day") : this.num(e.day, 2);
            case "c":
              return this.num(e.weekday);
            case "ccc":
              return u("short", !0);
            case "cccc":
              return u("long", !0);
            case "ccccc":
              return u("narrow", !0);
            case "E":
              return this.num(e.weekday);
            case "EEE":
              return u("short", !1);
            case "EEEE":
              return u("long", !1);
            case "EEEEE":
              return u("narrow", !1);
            case "L":
              return s ? i({ month: "numeric", day: "numeric" }, "month") : this.num(e.month);
            case "LL":
              return s ? i({ month: "2-digit", day: "numeric" }, "month") : this.num(e.month, 2);
            case "LLL":
              return l("short", !0);
            case "LLLL":
              return l("long", !0);
            case "LLLLL":
              return l("narrow", !0);
            case "M":
              return s ? i({ month: "numeric" }, "month") : this.num(e.month);
            case "MM":
              return s ? i({ month: "2-digit" }, "month") : this.num(e.month, 2);
            case "MMM":
              return l("short", !1);
            case "MMMM":
              return l("long", !1);
            case "MMMMM":
              return l("narrow", !1);
            case "y":
              return s ? i({ year: "numeric" }, "year") : this.num(e.year);
            case "yy":
              return s ? i({ year: "2-digit" }, "year") : this.num(e.year.toString().slice(-2), 2);
            case "yyyy":
              return s ? i({ year: "numeric" }, "year") : this.num(e.year, 4);
            case "yyyyyy":
              return s ? i({ year: "numeric" }, "year") : this.num(e.year, 6);
            case "G":
              return g("short");
            case "GG":
              return g("long");
            case "GGGGG":
              return g("narrow");
            case "kk":
              return this.num(e.weekYear.toString().slice(-2), 2);
            case "kkkk":
              return this.num(e.weekYear, 4);
            case "W":
              return this.num(e.weekNumber);
            case "WW":
              return this.num(e.weekNumber, 2);
            case "n":
              return this.num(e.localWeekNumber);
            case "nn":
              return this.num(e.localWeekNumber, 2);
            case "ii":
              return this.num(e.localWeekYear.toString().slice(-2), 2);
            case "iiii":
              return this.num(e.localWeekYear, 4);
            case "o":
              return this.num(e.ordinal);
            case "ooo":
              return this.num(e.ordinal, 3);
            case "q":
              return this.num(e.quarter);
            case "qq":
              return this.num(e.quarter, 2);
            case "X":
              return this.num(Math.floor(e.ts / 1e3));
            case "x":
              return this.num(e.ts);
            default:
              return d(w);
          }
        };
      return cs(t.parseFormat(r), D);
    }
    formatDurationFromString(e, r) {
      let n = (l) => {
          switch (l[0]) {
            case "S":
              return "millisecond";
            case "s":
              return "second";
            case "m":
              return "minute";
            case "h":
              return "hour";
            case "d":
              return "day";
            case "w":
              return "week";
            case "M":
              return "month";
            case "y":
              return "year";
            default:
              return null;
          }
        },
        s = (l) => (u) => {
          let d = n(u);
          return d ? this.num(l.get(d), u.length) : u;
        },
        i = t.parseFormat(r),
        a = i.reduce((l, { literal: u, val: d }) => (u ? l : l.concat(d)), []),
        o = e.shiftTo(...a.map(n).filter((l) => l));
      return cs(i, s(o));
    }
  };
var fs = /[A-Za-z_+-]{1,256}(?::?\/[A-Za-z0-9_+-]{1,256}(?:\/[A-Za-z0-9_+-]{1,256})?)?/;
function ct(...t) {
  let e = t.reduce((r, n) => r + n.source, "");
  return RegExp(`^${e}$`);
}
function dt(...t) {
  return (e) =>
    t
      .reduce(
        ([r, n, s], i) => {
          let [a, o, l] = i(e, s);
          return [{ ...r, ...a }, o || n, l];
        },
        [{}, null, 1],
      )
      .slice(0, 2);
}
function ft(t, ...e) {
  if (t == null) return [null, null];
  for (let [r, n] of e) {
    let s = r.exec(t);
    if (s) return n(s);
  }
  return [null, null];
}
function hs(...t) {
  return (e, r) => {
    let n = {},
      s;
    for (s = 0; s < t.length; s++) n[t[s]] = he(e[r + s]);
    return [n, null, r + s];
  };
}
var ms = /(?:(Z)|([+-]\d\d)(?::?(\d\d))?)/,
  Fa = `(?:${ms.source}?(?:\\[(${fs.source})\\])?)?`,
  sn = /(\d\d)(?::?(\d\d)(?::?(\d\d)(?:[.,](\d{1,30}))?)?)?/,
  ps = RegExp(`${sn.source}${Fa}`),
  an = RegExp(`(?:T${ps.source})?`),
  Wa = /([+-]\d{6}|\d{4})(?:-?(\d\d)(?:-?(\d\d))?)?/,
  La = /(\d{4})-?W(\d\d)(?:-?(\d))?/,
  Ra = /(\d{4})-?(\d{3})/,
  Za = hs("weekYear", "weekNumber", "weekDay"),
  Pa = hs("year", "ordinal"),
  za = /(\d{4})-(\d\d)-(\d\d)/,
  ys = RegExp(`${sn.source} ?(?:${ms.source}|(${fs.source}))?`),
  Va = RegExp(`(?: ${ys.source})?`);
function ut(t, e, r) {
  let n = t[e];
  return v(n) ? r : he(n);
}
function $a(t, e) {
  return [{ year: ut(t, e), month: ut(t, e + 1, 1), day: ut(t, e + 2, 1) }, null, e + 3];
}
function ht(t, e) {
  return [
    {
      hours: ut(t, e, 0),
      minutes: ut(t, e + 1, 0),
      seconds: ut(t, e + 2, 0),
      milliseconds: Bt(t[e + 3]),
    },
    null,
    e + 4,
  ];
}
function Kt(t, e) {
  let r = !t[e] && !t[e + 1],
    n = $e(t[e + 1], t[e + 2]),
    s = r ? null : F.instance(n);
  return [{}, s, e + 3];
}
function Qt(t, e) {
  let r = t[e] ? Z.create(t[e]) : null;
  return [{}, r, e + 1];
}
var ja = RegExp(`^T?${sn.source}$`),
  Ua =
    /^-?P(?:(?:(-?\d{1,20}(?:\.\d{1,20})?)Y)?(?:(-?\d{1,20}(?:\.\d{1,20})?)M)?(?:(-?\d{1,20}(?:\.\d{1,20})?)W)?(?:(-?\d{1,20}(?:\.\d{1,20})?)D)?(?:T(?:(-?\d{1,20}(?:\.\d{1,20})?)H)?(?:(-?\d{1,20}(?:\.\d{1,20})?)M)?(?:(-?\d{1,20})(?:[.,](-?\d{1,20}))?S)?)?)$/;
function Ha(t) {
  let [e, r, n, s, i, a, o, l, u] = t,
    d = e[0] === "-",
    g = l && l[0] === "-",
    D = (w, A = !1) => (w !== void 0 && (A || (w && d)) ? -w : w);
  return [
    {
      years: D(xe(r)),
      months: D(xe(n)),
      weeks: D(xe(s)),
      days: D(xe(i)),
      hours: D(xe(a)),
      minutes: D(xe(o)),
      seconds: D(xe(l), l === "-0"),
      milliseconds: D(Bt(u), g),
    },
  ];
}
var Ga = {
  GMT: 0,
  EDT: -240,
  EST: -300,
  CDT: -300,
  CST: -360,
  MDT: -360,
  MST: -420,
  PDT: -420,
  PST: -480,
};
function on(t, e, r, n, s, i, a) {
  let o = {
    year: e.length === 2 ? Jt(he(e)) : he(e),
    month: tn.indexOf(r) + 1,
    day: he(n),
    hour: he(s),
    minute: he(i),
  };
  return (
    a && (o.second = he(a)),
    t && (o.weekday = t.length > 3 ? rn.indexOf(t) + 1 : nn.indexOf(t) + 1),
    o
  );
}
var Ya =
  /^(?:(Mon|Tue|Wed|Thu|Fri|Sat|Sun),\s)?(\d{1,2})\s(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s(\d{2,4})\s(\d\d):(\d\d)(?::(\d\d))?\s(?:(UT|GMT|[ECMP][SD]T)|([Zz])|(?:([+-]\d\d)(\d\d)))$/;
function qa(t) {
  let [, e, r, n, s, i, a, o, l, u, d, g] = t,
    D = on(e, s, n, r, i, a, o),
    w;
  return (l ? (w = Ga[l]) : u ? (w = 0) : (w = $e(d, g)), [D, new F(w)]);
}
function Ba(t) {
  return t
    .replace(/\([^()]*\)|[\n\t]/g, " ")
    .replace(/(\s\s+)/g, " ")
    .trim();
}
var Ja =
    /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (\d\d) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) (\d{4}) (\d\d):(\d\d):(\d\d) GMT$/,
  Ka =
    /^(Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday), (\d\d)-(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)-(\d\d) (\d\d):(\d\d):(\d\d) GMT$/,
  Qa =
    /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) ( \d|\d\d) (\d\d):(\d\d):(\d\d) (\d{4})$/;
function ds(t) {
  let [, e, r, n, s, i, a, o] = t;
  return [on(e, s, n, r, i, a, o), F.utcInstance];
}
function Xa(t) {
  let [, e, r, n, s, i, a, o] = t;
  return [on(e, o, r, n, s, i, a), F.utcInstance];
}
var eo = ct(Wa, an),
  to = ct(La, an),
  ro = ct(Ra, an),
  no = ct(ps),
  gs = dt($a, ht, Kt, Qt),
  so = dt(Za, ht, Kt, Qt),
  io = dt(Pa, ht, Kt, Qt),
  ao = dt(ht, Kt, Qt);
function vs(t) {
  return ft(t, [eo, gs], [to, so], [ro, io], [no, ao]);
}
function ws(t) {
  return ft(Ba(t), [Ya, qa]);
}
function _s(t) {
  return ft(t, [Ja, ds], [Ka, ds], [Qa, Xa]);
}
function Ts(t) {
  return ft(t, [Ua, Ha]);
}
var oo = dt(ht);
function bs(t) {
  return ft(t, [ja, oo]);
}
var lo = ct(za, Va),
  uo = ct(ys),
  co = dt(ht, Kt, Qt);
function ks(t) {
  return ft(t, [lo, gs], [uo, co]);
}
var xs = "Invalid Duration",
  Es = {
    weeks: {
      days: 7,
      hours: 168,
      minutes: 10080,
      seconds: 10080 * 60,
      milliseconds: 10080 * 60 * 1e3,
    },
    days: { hours: 24, minutes: 1440, seconds: 1440 * 60, milliseconds: 1440 * 60 * 1e3 },
    hours: { minutes: 60, seconds: 3600, milliseconds: 3600 * 1e3 },
    minutes: { seconds: 60, milliseconds: 60 * 1e3 },
    seconds: { milliseconds: 1e3 },
  },
  fo = {
    years: {
      quarters: 4,
      months: 12,
      weeks: 52,
      days: 365,
      hours: 365 * 24,
      minutes: 365 * 24 * 60,
      seconds: 365 * 24 * 60 * 60,
      milliseconds: 365 * 24 * 60 * 60 * 1e3,
    },
    quarters: {
      months: 3,
      weeks: 13,
      days: 91,
      hours: 2184,
      minutes: 2184 * 60,
      seconds: 2184 * 60 * 60,
      milliseconds: 2184 * 60 * 60 * 1e3,
    },
    months: {
      weeks: 4,
      days: 30,
      hours: 720,
      minutes: 720 * 60,
      seconds: 720 * 60 * 60,
      milliseconds: 720 * 60 * 60 * 1e3,
    },
    ...Es,
  },
  B = 146097 / 400,
  mt = 146097 / 4800,
  ho = {
    years: {
      quarters: 4,
      months: 12,
      weeks: B / 7,
      days: B,
      hours: B * 24,
      minutes: B * 24 * 60,
      seconds: B * 24 * 60 * 60,
      milliseconds: B * 24 * 60 * 60 * 1e3,
    },
    quarters: {
      months: 3,
      weeks: B / 28,
      days: B / 4,
      hours: (B * 24) / 4,
      minutes: (B * 24 * 60) / 4,
      seconds: (B * 24 * 60 * 60) / 4,
      milliseconds: (B * 24 * 60 * 60 * 1e3) / 4,
    },
    months: {
      weeks: mt / 7,
      days: mt,
      hours: mt * 24,
      minutes: mt * 24 * 60,
      seconds: mt * 24 * 60 * 60,
      milliseconds: mt * 24 * 60 * 60 * 1e3,
    },
    ...Es,
  },
  He = [
    "years",
    "quarters",
    "months",
    "weeks",
    "days",
    "hours",
    "minutes",
    "seconds",
    "milliseconds",
  ],
  mo = He.slice(0).reverse();
function Se(t, e, r = !1) {
  let n = {
    values: r ? e.values : { ...t.values, ...(e.values || {}) },
    loc: t.loc.clone(e.loc),
    conversionAccuracy: e.conversionAccuracy || t.conversionAccuracy,
    matrix: e.matrix || t.matrix,
  };
  return new N(n);
}
function Os(t, e) {
  let r = e.milliseconds ?? 0;
  for (let n of mo.slice(1)) e[n] && (r += e[n] * t[n].milliseconds);
  return r;
}
function Ss(t, e) {
  let r = Os(t, e) < 0 ? -1 : 1;
  (He.reduceRight((n, s) => {
    if (v(e[s])) return n;
    if (n) {
      let i = e[n] * r,
        a = t[s][n],
        o = Math.floor(i / a);
      ((e[s] += o * r), (e[n] -= o * a * r));
    }
    return s;
  }, null),
    He.reduce((n, s) => {
      if (v(e[s])) return n;
      if (n) {
        let i = e[n] % 1;
        ((e[n] -= i), (e[s] += i * t[n][s]));
      }
      return s;
    }, null));
}
function po(t) {
  let e = {};
  for (let [r, n] of Object.entries(t)) n !== 0 && (e[r] = n);
  return e;
}
var N = class t {
  constructor(e) {
    let r = e.conversionAccuracy === "longterm" || !1,
      n = r ? ho : fo;
    (e.matrix && (n = e.matrix),
      (this.values = e.values),
      (this.loc = e.loc || O.create()),
      (this.conversionAccuracy = r ? "longterm" : "casual"),
      (this.invalid = e.invalid || null),
      (this.matrix = n),
      (this.isLuxonDuration = !0));
  }
  static fromMillis(e, r) {
    return t.fromObject({ milliseconds: e }, r);
  }
  static fromObject(e, r = {}) {
    if (e == null || typeof e != "object")
      throw new C(
        `Duration.fromObject: argument expected to be an object, got ${e === null ? "null" : typeof e}`,
      );
    return new t({
      values: lt(e, t.normalizeUnit),
      loc: O.fromObject(r),
      conversionAccuracy: r.conversionAccuracy,
      matrix: r.matrix,
    });
  }
  static fromDurationLike(e) {
    if (oe(e)) return t.fromMillis(e);
    if (t.isDuration(e)) return e;
    if (typeof e == "object") return t.fromObject(e);
    throw new C(`Unknown duration argument ${e} of type ${typeof e}`);
  }
  static fromISO(e, r) {
    let [n] = Ts(e);
    return n
      ? t.fromObject(n, r)
      : t.invalid("unparsable", `the input "${e}" can't be parsed as ISO 8601`);
  }
  static fromISOTime(e, r) {
    let [n] = bs(e);
    return n
      ? t.fromObject(n, r)
      : t.invalid("unparsable", `the input "${e}" can't be parsed as ISO 8601`);
  }
  static invalid(e, r = null) {
    if (!e) throw new C("need to specify a reason the Duration is invalid");
    let n = e instanceof W ? e : new W(e, r);
    if (S.throwOnInvalid) throw new lr(n);
    return new t({ invalid: n });
  }
  static normalizeUnit(e) {
    let r = {
      year: "years",
      years: "years",
      quarter: "quarters",
      quarters: "quarters",
      month: "months",
      months: "months",
      week: "weeks",
      weeks: "weeks",
      day: "days",
      days: "days",
      hour: "hours",
      hours: "hours",
      minute: "minutes",
      minutes: "minutes",
      second: "seconds",
      seconds: "seconds",
      millisecond: "milliseconds",
      milliseconds: "milliseconds",
    }[e && e.toLowerCase()];
    if (!r) throw new nt(e);
    return r;
  }
  static isDuration(e) {
    return (e && e.isLuxonDuration) || !1;
  }
  get locale() {
    return this.isValid ? this.loc.locale : null;
  }
  get numberingSystem() {
    return this.isValid ? this.loc.numberingSystem : null;
  }
  toFormat(e, r = {}) {
    let n = { ...r, floor: r.round !== !1 && r.floor !== !1 };
    return this.isValid ? L.create(this.loc, n).formatDurationFromString(this, e) : xs;
  }
  toHuman(e = {}) {
    if (!this.isValid) return xs;
    let r = He.map((n) => {
      let s = this.values[n];
      return v(s)
        ? null
        : this.loc
            .numberFormatter({ style: "unit", unitDisplay: "long", ...e, unit: n.slice(0, -1) })
            .format(s);
    }).filter((n) => n);
    return this.loc
      .listFormatter({ type: "conjunction", style: e.listStyle || "narrow", ...e })
      .format(r);
  }
  toObject() {
    return this.isValid ? { ...this.values } : {};
  }
  toISO() {
    if (!this.isValid) return null;
    let e = "P";
    return (
      this.years !== 0 && (e += this.years + "Y"),
      (this.months !== 0 || this.quarters !== 0) && (e += this.months + this.quarters * 3 + "M"),
      this.weeks !== 0 && (e += this.weeks + "W"),
      this.days !== 0 && (e += this.days + "D"),
      (this.hours !== 0 || this.minutes !== 0 || this.seconds !== 0 || this.milliseconds !== 0) &&
        (e += "T"),
      this.hours !== 0 && (e += this.hours + "H"),
      this.minutes !== 0 && (e += this.minutes + "M"),
      (this.seconds !== 0 || this.milliseconds !== 0) &&
        (e += it(this.seconds + this.milliseconds / 1e3, 3) + "S"),
      e === "P" && (e += "T0S"),
      e
    );
  }
  toISOTime(e = {}) {
    if (!this.isValid) return null;
    let r = this.toMillis();
    return r < 0 || r >= 864e5
      ? null
      : ((e = {
          suppressMilliseconds: !1,
          suppressSeconds: !1,
          includePrefix: !1,
          format: "extended",
          ...e,
          includeOffset: !1,
        }),
        I.fromMillis(r, { zone: "UTC" }).toISOTime(e));
  }
  toJSON() {
    return this.toISO();
  }
  toString() {
    return this.toISO();
  }
  [Symbol.for("nodejs.util.inspect.custom")]() {
    return this.isValid
      ? `Duration { values: ${JSON.stringify(this.values)} }`
      : `Duration { Invalid, reason: ${this.invalidReason} }`;
  }
  toMillis() {
    return this.isValid ? Os(this.matrix, this.values) : NaN;
  }
  valueOf() {
    return this.toMillis();
  }
  plus(e) {
    if (!this.isValid) return this;
    let r = t.fromDurationLike(e),
      n = {};
    for (let s of He) (ke(r.values, s) || ke(this.values, s)) && (n[s] = r.get(s) + this.get(s));
    return Se(this, { values: n }, !0);
  }
  minus(e) {
    if (!this.isValid) return this;
    let r = t.fromDurationLike(e);
    return this.plus(r.negate());
  }
  mapUnits(e) {
    if (!this.isValid) return this;
    let r = {};
    for (let n of Object.keys(this.values)) r[n] = en(e(this.values[n], n));
    return Se(this, { values: r }, !0);
  }
  get(e) {
    return this[t.normalizeUnit(e)];
  }
  set(e) {
    if (!this.isValid) return this;
    let r = { ...this.values, ...lt(e, t.normalizeUnit) };
    return Se(this, { values: r });
  }
  reconfigure({ locale: e, numberingSystem: r, conversionAccuracy: n, matrix: s } = {}) {
    let a = {
      loc: this.loc.clone({ locale: e, numberingSystem: r }),
      matrix: s,
      conversionAccuracy: n,
    };
    return Se(this, a);
  }
  as(e) {
    return this.isValid ? this.shiftTo(e).get(e) : NaN;
  }
  normalize() {
    if (!this.isValid) return this;
    let e = this.toObject();
    return (Ss(this.matrix, e), Se(this, { values: e }, !0));
  }
  rescale() {
    if (!this.isValid) return this;
    let e = po(this.normalize().shiftToAll().toObject());
    return Se(this, { values: e }, !0);
  }
  shiftTo(...e) {
    if (!this.isValid) return this;
    if (e.length === 0) return this;
    e = e.map((a) => t.normalizeUnit(a));
    let r = {},
      n = {},
      s = this.toObject(),
      i;
    for (let a of He)
      if (e.indexOf(a) >= 0) {
        i = a;
        let o = 0;
        for (let u in n) ((o += this.matrix[u][a] * n[u]), (n[u] = 0));
        oe(s[a]) && (o += s[a]);
        let l = Math.trunc(o);
        ((r[a] = l), (n[a] = (o * 1e3 - l * 1e3) / 1e3));
      } else oe(s[a]) && (n[a] = s[a]);
    for (let a in n) n[a] !== 0 && (r[i] += a === i ? n[a] : n[a] / this.matrix[i][a]);
    return (Ss(this.matrix, r), Se(this, { values: r }, !0));
  }
  shiftToAll() {
    return this.isValid
      ? this.shiftTo(
          "years",
          "months",
          "weeks",
          "days",
          "hours",
          "minutes",
          "seconds",
          "milliseconds",
        )
      : this;
  }
  negate() {
    if (!this.isValid) return this;
    let e = {};
    for (let r of Object.keys(this.values)) e[r] = this.values[r] === 0 ? 0 : -this.values[r];
    return Se(this, { values: e }, !0);
  }
  get years() {
    return this.isValid ? this.values.years || 0 : NaN;
  }
  get quarters() {
    return this.isValid ? this.values.quarters || 0 : NaN;
  }
  get months() {
    return this.isValid ? this.values.months || 0 : NaN;
  }
  get weeks() {
    return this.isValid ? this.values.weeks || 0 : NaN;
  }
  get days() {
    return this.isValid ? this.values.days || 0 : NaN;
  }
  get hours() {
    return this.isValid ? this.values.hours || 0 : NaN;
  }
  get minutes() {
    return this.isValid ? this.values.minutes || 0 : NaN;
  }
  get seconds() {
    return this.isValid ? this.values.seconds || 0 : NaN;
  }
  get milliseconds() {
    return this.isValid ? this.values.milliseconds || 0 : NaN;
  }
  get isValid() {
    return this.invalid === null;
  }
  get invalidReason() {
    return this.invalid ? this.invalid.reason : null;
  }
  get invalidExplanation() {
    return this.invalid ? this.invalid.explanation : null;
  }
  equals(e) {
    if (!this.isValid || !e.isValid || !this.loc.equals(e.loc)) return !1;
    function r(n, s) {
      return n === void 0 || n === 0 ? s === void 0 || s === 0 : n === s;
    }
    for (let n of He) if (!r(this.values[n], e.values[n])) return !1;
    return !0;
  }
};
var pt = "Invalid Interval";
function yo(t, e) {
  return !t || !t.isValid
    ? me.invalid("missing or invalid start")
    : !e || !e.isValid
      ? me.invalid("missing or invalid end")
      : e < t
        ? me.invalid(
            "end before start",
            `The end of an interval must be after its start, but you had start=${t.toISO()} and end=${e.toISO()}`,
          )
        : null;
}
var me = class t {
  constructor(e) {
    ((this.s = e.start),
      (this.e = e.end),
      (this.invalid = e.invalid || null),
      (this.isLuxonInterval = !0));
  }
  static invalid(e, r = null) {
    if (!e) throw new C("need to specify a reason the Interval is invalid");
    let n = e instanceof W ? e : new W(e, r);
    if (S.throwOnInvalid) throw new or(n);
    return new t({ invalid: n });
  }
  static fromDateTimes(e, r) {
    let n = yt(e),
      s = yt(r),
      i = yo(n, s);
    return i ?? new t({ start: n, end: s });
  }
  static after(e, r) {
    let n = N.fromDurationLike(r),
      s = yt(e);
    return t.fromDateTimes(s, s.plus(n));
  }
  static before(e, r) {
    let n = N.fromDurationLike(r),
      s = yt(e);
    return t.fromDateTimes(s.minus(n), s);
  }
  static fromISO(e, r) {
    let [n, s] = (e || "").split("/", 2);
    if (n && s) {
      let i, a;
      try {
        ((i = I.fromISO(n, r)), (a = i.isValid));
      } catch {
        a = !1;
      }
      let o, l;
      try {
        ((o = I.fromISO(s, r)), (l = o.isValid));
      } catch {
        l = !1;
      }
      if (a && l) return t.fromDateTimes(i, o);
      if (a) {
        let u = N.fromISO(s, r);
        if (u.isValid) return t.after(i, u);
      } else if (l) {
        let u = N.fromISO(n, r);
        if (u.isValid) return t.before(o, u);
      }
    }
    return t.invalid("unparsable", `the input "${e}" can't be parsed as ISO 8601`);
  }
  static isInterval(e) {
    return (e && e.isLuxonInterval) || !1;
  }
  get start() {
    return this.isValid ? this.s : null;
  }
  get end() {
    return this.isValid ? this.e : null;
  }
  get isValid() {
    return this.invalidReason === null;
  }
  get invalidReason() {
    return this.invalid ? this.invalid.reason : null;
  }
  get invalidExplanation() {
    return this.invalid ? this.invalid.explanation : null;
  }
  length(e = "milliseconds") {
    return this.isValid ? this.toDuration(e).get(e) : NaN;
  }
  count(e = "milliseconds", r) {
    if (!this.isValid) return NaN;
    let n = this.start.startOf(e, r),
      s;
    return (
      r?.useLocaleWeeks ? (s = this.end.reconfigure({ locale: n.locale })) : (s = this.end),
      (s = s.startOf(e, r)),
      Math.floor(s.diff(n, e).get(e)) + (s.valueOf() !== this.end.valueOf())
    );
  }
  hasSame(e) {
    return this.isValid ? this.isEmpty() || this.e.minus(1).hasSame(this.s, e) : !1;
  }
  isEmpty() {
    return this.s.valueOf() === this.e.valueOf();
  }
  isAfter(e) {
    return this.isValid ? this.s > e : !1;
  }
  isBefore(e) {
    return this.isValid ? this.e <= e : !1;
  }
  contains(e) {
    return this.isValid ? this.s <= e && this.e > e : !1;
  }
  set({ start: e, end: r } = {}) {
    return this.isValid ? t.fromDateTimes(e || this.s, r || this.e) : this;
  }
  splitAt(...e) {
    if (!this.isValid) return [];
    let r = e
        .map(yt)
        .filter((a) => this.contains(a))
        .sort((a, o) => a.toMillis() - o.toMillis()),
      n = [],
      { s } = this,
      i = 0;
    for (; s < this.e; ) {
      let a = r[i] || this.e,
        o = +a > +this.e ? this.e : a;
      (n.push(t.fromDateTimes(s, o)), (s = o), (i += 1));
    }
    return n;
  }
  splitBy(e) {
    let r = N.fromDurationLike(e);
    if (!this.isValid || !r.isValid || r.as("milliseconds") === 0) return [];
    let { s: n } = this,
      s = 1,
      i,
      a = [];
    for (; n < this.e; ) {
      let o = this.start.plus(r.mapUnits((l) => l * s));
      ((i = +o > +this.e ? this.e : o), a.push(t.fromDateTimes(n, i)), (n = i), (s += 1));
    }
    return a;
  }
  divideEqually(e) {
    return this.isValid ? this.splitBy(this.length() / e).slice(0, e) : [];
  }
  overlaps(e) {
    return this.e > e.s && this.s < e.e;
  }
  abutsStart(e) {
    return this.isValid ? +this.e == +e.s : !1;
  }
  abutsEnd(e) {
    return this.isValid ? +e.e == +this.s : !1;
  }
  engulfs(e) {
    return this.isValid ? this.s <= e.s && this.e >= e.e : !1;
  }
  equals(e) {
    return !this.isValid || !e.isValid ? !1 : this.s.equals(e.s) && this.e.equals(e.e);
  }
  intersection(e) {
    if (!this.isValid) return this;
    let r = this.s > e.s ? this.s : e.s,
      n = this.e < e.e ? this.e : e.e;
    return r >= n ? null : t.fromDateTimes(r, n);
  }
  union(e) {
    if (!this.isValid) return this;
    let r = this.s < e.s ? this.s : e.s,
      n = this.e > e.e ? this.e : e.e;
    return t.fromDateTimes(r, n);
  }
  static merge(e) {
    let [r, n] = e
      .sort((s, i) => s.s - i.s)
      .reduce(
        ([s, i], a) =>
          i ? (i.overlaps(a) || i.abutsStart(a) ? [s, i.union(a)] : [s.concat([i]), a]) : [s, a],
        [[], null],
      );
    return (n && r.push(n), r);
  }
  static xor(e) {
    let r = null,
      n = 0,
      s = [],
      i = e.map((l) => [
        { time: l.s, type: "s" },
        { time: l.e, type: "e" },
      ]),
      a = Array.prototype.concat(...i),
      o = a.sort((l, u) => l.time - u.time);
    for (let l of o)
      ((n += l.type === "s" ? 1 : -1),
        n === 1
          ? (r = l.time)
          : (r && +r != +l.time && s.push(t.fromDateTimes(r, l.time)), (r = null)));
    return t.merge(s);
  }
  difference(...e) {
    return t
      .xor([this].concat(e))
      .map((r) => this.intersection(r))
      .filter((r) => r && !r.isEmpty());
  }
  toString() {
    return this.isValid ? `[${this.s.toISO()} \u2013 ${this.e.toISO()})` : pt;
  }
  [Symbol.for("nodejs.util.inspect.custom")]() {
    return this.isValid
      ? `Interval { start: ${this.s.toISO()}, end: ${this.e.toISO()} }`
      : `Interval { Invalid, reason: ${this.invalidReason} }`;
  }
  toLocaleString(e = we, r = {}) {
    return this.isValid ? L.create(this.s.loc.clone(r), e).formatInterval(this) : pt;
  }
  toISO(e) {
    return this.isValid ? `${this.s.toISO(e)}/${this.e.toISO(e)}` : pt;
  }
  toISODate() {
    return this.isValid ? `${this.s.toISODate()}/${this.e.toISODate()}` : pt;
  }
  toISOTime(e) {
    return this.isValid ? `${this.s.toISOTime(e)}/${this.e.toISOTime(e)}` : pt;
  }
  toFormat(e, { separator: r = " \u2013 " } = {}) {
    return this.isValid ? `${this.s.toFormat(e)}${r}${this.e.toFormat(e)}` : pt;
  }
  toDuration(e, r) {
    return this.isValid ? this.e.diff(this.s, e, r) : N.invalid(this.invalidReason);
  }
  mapEndpoints(e) {
    return t.fromDateTimes(e(this.s), e(this.e));
  }
};
var pe = class {
  static hasDST(e = S.defaultZone) {
    let r = I.now().setZone(e).set({ month: 12 });
    return !e.isUniversal && r.offset !== r.set({ month: 6 }).offset;
  }
  static isValidIANAZone(e) {
    return Z.isValidZone(e);
  }
  static normalizeZone(e) {
    return te(e, S.defaultZone);
  }
  static getStartOfWeek({ locale: e = null, locObj: r = null } = {}) {
    return (r || O.create(e)).getStartOfWeek();
  }
  static getMinimumDaysInFirstWeek({ locale: e = null, locObj: r = null } = {}) {
    return (r || O.create(e)).getMinDaysInFirstWeek();
  }
  static getWeekendWeekdays({ locale: e = null, locObj: r = null } = {}) {
    return (r || O.create(e)).getWeekendDays().slice();
  }
  static months(
    e = "long",
    {
      locale: r = null,
      numberingSystem: n = null,
      locObj: s = null,
      outputCalendar: i = "gregory",
    } = {},
  ) {
    return (s || O.create(r, n, i)).months(e);
  }
  static monthsFormat(
    e = "long",
    {
      locale: r = null,
      numberingSystem: n = null,
      locObj: s = null,
      outputCalendar: i = "gregory",
    } = {},
  ) {
    return (s || O.create(r, n, i)).months(e, !0);
  }
  static weekdays(
    e = "long",
    { locale: r = null, numberingSystem: n = null, locObj: s = null } = {},
  ) {
    return (s || O.create(r, n, null)).weekdays(e);
  }
  static weekdaysFormat(
    e = "long",
    { locale: r = null, numberingSystem: n = null, locObj: s = null } = {},
  ) {
    return (s || O.create(r, n, null)).weekdays(e, !0);
  }
  static meridiems({ locale: e = null } = {}) {
    return O.create(e).meridiems();
  }
  static eras(e = "short", { locale: r = null } = {}) {
    return O.create(r, null, "gregory").eras(e);
  }
  static features() {
    return { relative: mr(), localeWeek: pr() };
  }
};
function Is(t, e) {
  let r = (s) => s.toUTC(0, { keepLocalTime: !0 }).startOf("day").valueOf(),
    n = r(e) - r(t);
  return Math.floor(N.fromMillis(n).as("days"));
}
function go(t, e, r) {
  let n = [
      ["years", (l, u) => u.year - l.year],
      ["quarters", (l, u) => u.quarter - l.quarter + (u.year - l.year) * 4],
      ["months", (l, u) => u.month - l.month + (u.year - l.year) * 12],
      [
        "weeks",
        (l, u) => {
          let d = Is(l, u);
          return (d - (d % 7)) / 7;
        },
      ],
      ["days", Is],
    ],
    s = {},
    i = t,
    a,
    o;
  for (let [l, u] of n)
    r.indexOf(l) >= 0 &&
      ((a = l),
      (s[l] = u(t, e)),
      (o = i.plus(s)),
      o > e ? (s[l]--, (t = i.plus(s)), t > e && ((o = t), s[l]--, (t = i.plus(s)))) : (t = o));
  return [t, s, o, a];
}
function Ds(t, e, r, n) {
  let [s, i, a, o] = go(t, e, r),
    l = e - s,
    u = r.filter((g) => ["hours", "minutes", "seconds", "milliseconds"].indexOf(g) >= 0);
  u.length === 0 &&
    (a < e && (a = s.plus({ [o]: 1 })), a !== s && (i[o] = (i[o] || 0) + l / (a - s)));
  let d = N.fromObject(i, n);
  return u.length > 0
    ? N.fromMillis(l, n)
        .shiftTo(...u)
        .plus(d)
    : d;
}
var ln = {
    arab: "[\u0660-\u0669]",
    arabext: "[\u06F0-\u06F9]",
    bali: "[\u1B50-\u1B59]",
    beng: "[\u09E6-\u09EF]",
    deva: "[\u0966-\u096F]",
    fullwide: "[\uFF10-\uFF19]",
    gujr: "[\u0AE6-\u0AEF]",
    hanidec: "[\u3007|\u4E00|\u4E8C|\u4E09|\u56DB|\u4E94|\u516D|\u4E03|\u516B|\u4E5D]",
    khmr: "[\u17E0-\u17E9]",
    knda: "[\u0CE6-\u0CEF]",
    laoo: "[\u0ED0-\u0ED9]",
    limb: "[\u1946-\u194F]",
    mlym: "[\u0D66-\u0D6F]",
    mong: "[\u1810-\u1819]",
    mymr: "[\u1040-\u1049]",
    orya: "[\u0B66-\u0B6F]",
    tamldec: "[\u0BE6-\u0BEF]",
    telu: "[\u0C66-\u0C6F]",
    thai: "[\u0E50-\u0E59]",
    tibt: "[\u0F20-\u0F29]",
    latn: "\\d",
  },
  Ms = {
    arab: [1632, 1641],
    arabext: [1776, 1785],
    bali: [6992, 7001],
    beng: [2534, 2543],
    deva: [2406, 2415],
    fullwide: [65296, 65303],
    gujr: [2790, 2799],
    khmr: [6112, 6121],
    knda: [3302, 3311],
    laoo: [3792, 3801],
    limb: [6470, 6479],
    mlym: [3430, 3439],
    mong: [6160, 6169],
    mymr: [4160, 4169],
    orya: [2918, 2927],
    tamldec: [3046, 3055],
    telu: [3174, 3183],
    thai: [3664, 3673],
    tibt: [3872, 3881],
  },
  vo = ln.hanidec.replace(/[\[|\]]/g, "").split("");
function Ns(t) {
  let e = parseInt(t, 10);
  if (isNaN(e)) {
    e = "";
    for (let r = 0; r < t.length; r++) {
      let n = t.charCodeAt(r);
      if (t[r].search(ln.hanidec) !== -1) e += vo.indexOf(t[r]);
      else
        for (let s in Ms) {
          let [i, a] = Ms[s];
          n >= i && n <= a && (e += n - i);
        }
    }
    return parseInt(e, 10);
  } else return e;
}
function J({ numberingSystem: t }, e = "") {
  return new RegExp(`${ln[t || "latn"]}${e}`);
}
var wo = "missing Intl.DateTimeFormat.formatToParts support";
function E(t, e = (r) => r) {
  return { regex: t, deser: ([r]) => e(Ns(r)) };
}
var _o = "\xA0",
  Fs = `[ ${_o}]`,
  Ws = new RegExp(Fs, "g");
function To(t) {
  return t.replace(/\./g, "\\.?").replace(Ws, Fs);
}
function Cs(t) {
  return t.replace(/\./g, "").replace(Ws, " ").toLowerCase();
}
function re(t, e) {
  return t === null
    ? null
    : {
        regex: RegExp(t.map(To).join("|")),
        deser: ([r]) => t.findIndex((n) => Cs(r) === Cs(n)) + e,
      };
}
function As(t, e) {
  return { regex: t, deser: ([, r, n]) => $e(r, n), groups: e };
}
function wr(t) {
  return { regex: t, deser: ([e]) => e };
}
function bo(t) {
  return t.replace(/[\-\[\]{}()*+?.,\\\^$|#\s]/g, "\\$&");
}
function ko(t, e) {
  let r = J(e),
    n = J(e, "{2}"),
    s = J(e, "{3}"),
    i = J(e, "{4}"),
    a = J(e, "{6}"),
    o = J(e, "{1,2}"),
    l = J(e, "{1,3}"),
    u = J(e, "{1,6}"),
    d = J(e, "{1,9}"),
    g = J(e, "{2,4}"),
    D = J(e, "{4,6}"),
    w = (se) => ({ regex: RegExp(bo(se.val)), deser: ([qe]) => qe, literal: !0 }),
    Ye = ((se) => {
      if (t.literal) return w(se);
      switch (se.val) {
        case "G":
          return re(e.eras("short"), 0);
        case "GG":
          return re(e.eras("long"), 0);
        case "y":
          return E(u);
        case "yy":
          return E(g, Jt);
        case "yyyy":
          return E(i);
        case "yyyyy":
          return E(D);
        case "yyyyyy":
          return E(a);
        case "M":
          return E(o);
        case "MM":
          return E(n);
        case "MMM":
          return re(e.months("short", !0), 1);
        case "MMMM":
          return re(e.months("long", !0), 1);
        case "L":
          return E(o);
        case "LL":
          return E(n);
        case "LLL":
          return re(e.months("short", !1), 1);
        case "LLLL":
          return re(e.months("long", !1), 1);
        case "d":
          return E(o);
        case "dd":
          return E(n);
        case "o":
          return E(l);
        case "ooo":
          return E(s);
        case "HH":
          return E(n);
        case "H":
          return E(o);
        case "hh":
          return E(n);
        case "h":
          return E(o);
        case "mm":
          return E(n);
        case "m":
          return E(o);
        case "q":
          return E(o);
        case "qq":
          return E(n);
        case "s":
          return E(o);
        case "ss":
          return E(n);
        case "S":
          return E(l);
        case "SSS":
          return E(s);
        case "u":
          return wr(d);
        case "uu":
          return wr(o);
        case "uuu":
          return E(r);
        case "a":
          return re(e.meridiems(), 0);
        case "kkkk":
          return E(i);
        case "kk":
          return E(g, Jt);
        case "W":
          return E(o);
        case "WW":
          return E(n);
        case "E":
        case "c":
          return E(r);
        case "EEE":
          return re(e.weekdays("short", !1), 1);
        case "EEEE":
          return re(e.weekdays("long", !1), 1);
        case "ccc":
          return re(e.weekdays("short", !0), 1);
        case "cccc":
          return re(e.weekdays("long", !0), 1);
        case "Z":
        case "ZZ":
          return As(new RegExp(`([+-]${o.source})(?::(${n.source}))?`), 2);
        case "ZZZ":
          return As(new RegExp(`([+-]${o.source})(${n.source})?`), 2);
        case "z":
          return wr(/[a-z_+-/]{1,256}?/i);
        case " ":
          return wr(/[^\S\n\r]/);
        default:
          return w(se);
      }
    })(t) || { invalidReason: wo };
  return ((Ye.token = t), Ye);
}
var xo = {
  year: { "2-digit": "yy", numeric: "yyyyy" },
  month: { numeric: "M", "2-digit": "MM", short: "MMM", long: "MMMM" },
  day: { numeric: "d", "2-digit": "dd" },
  weekday: { short: "EEE", long: "EEEE" },
  dayperiod: "a",
  dayPeriod: "a",
  hour12: { numeric: "h", "2-digit": "hh" },
  hour24: { numeric: "H", "2-digit": "HH" },
  minute: { numeric: "m", "2-digit": "mm" },
  second: { numeric: "s", "2-digit": "ss" },
  timeZoneName: { long: "ZZZZZ", short: "ZZZ" },
};
function So(t, e, r) {
  let { type: n, value: s } = t;
  if (n === "literal") {
    let l = /^\s+$/.test(s);
    return { literal: !l, val: l ? " " : s };
  }
  let i = e[n],
    a = n;
  n === "hour" &&
    (e.hour12 != null
      ? (a = e.hour12 ? "hour12" : "hour24")
      : e.hourCycle != null
        ? e.hourCycle === "h11" || e.hourCycle === "h12"
          ? (a = "hour12")
          : (a = "hour24")
        : (a = r.hour12 ? "hour12" : "hour24"));
  let o = xo[a];
  if ((typeof o == "object" && (o = o[i]), o)) return { literal: !1, val: o };
}
function Eo(t) {
  return [`^${t.map((r) => r.regex).reduce((r, n) => `${r}(${n.source})`, "")}$`, t];
}
function Oo(t, e, r) {
  let n = t.match(e);
  if (n) {
    let s = {},
      i = 1;
    for (let a in r)
      if (ke(r, a)) {
        let o = r[a],
          l = o.groups ? o.groups + 1 : 1;
        (!o.literal && o.token && (s[o.token.val[0]] = o.deser(n.slice(i, i + l))), (i += l));
      }
    return [n, s];
  } else return [n, {}];
}
function Io(t) {
  let e = (i) => {
      switch (i) {
        case "S":
          return "millisecond";
        case "s":
          return "second";
        case "m":
          return "minute";
        case "h":
        case "H":
          return "hour";
        case "d":
          return "day";
        case "o":
          return "ordinal";
        case "L":
        case "M":
          return "month";
        case "y":
          return "year";
        case "E":
        case "c":
          return "weekday";
        case "W":
          return "weekNumber";
        case "k":
          return "weekYear";
        case "q":
          return "quarter";
        default:
          return null;
      }
    },
    r = null,
    n;
  return (
    v(t.z) || (r = Z.create(t.z)),
    v(t.Z) || (r || (r = new F(t.Z)), (n = t.Z)),
    v(t.q) || (t.M = (t.q - 1) * 3 + 1),
    v(t.h) || (t.h < 12 && t.a === 1 ? (t.h += 12) : t.h === 12 && t.a === 0 && (t.h = 0)),
    t.G === 0 && t.y && (t.y = -t.y),
    v(t.u) || (t.S = Bt(t.u)),
    [
      Object.keys(t).reduce((i, a) => {
        let o = e(a);
        return (o && (i[o] = t[a]), i);
      }, {}),
      r,
      n,
    ]
  );
}
var un = null;
function Do() {
  return (un || (un = I.fromMillis(1555555555555)), un);
}
function Mo(t, e) {
  if (t.literal) return t;
  let r = L.macroTokenToFormatOpts(t.val),
    n = fn(r, e);
  return n == null || n.includes(void 0) ? t : n;
}
function cn(t, e) {
  return Array.prototype.concat(...t.map((r) => Mo(r, e)));
}
function dn(t, e, r) {
  let n = cn(L.parseFormat(r), t),
    s = n.map((a) => ko(a, t)),
    i = s.find((a) => a.invalidReason);
  if (i) return { input: e, tokens: n, invalidReason: i.invalidReason };
  {
    let [a, o] = Eo(s),
      l = RegExp(a, "i"),
      [u, d] = Oo(e, l, o),
      [g, D, w] = d ? Io(d) : [null, null, void 0];
    if (ke(d, "a") && ke(d, "H"))
      throw new Q("Can't include meridiem when specifying 24-hour format");
    return {
      input: e,
      tokens: n,
      regex: l,
      rawMatches: u,
      matches: d,
      result: g,
      zone: D,
      specificOffset: w,
    };
  }
}
function Ls(t, e, r) {
  let { result: n, zone: s, specificOffset: i, invalidReason: a } = dn(t, e, r);
  return [n, s, i, a];
}
function fn(t, e) {
  if (!t) return null;
  let n = L.create(e, t).dtFormatter(Do()),
    s = n.formatToParts(),
    i = n.resolvedOptions();
  return s.map((a) => So(a, t, i));
}
var hn = "Invalid DateTime",
  Rs = 864e13;
function _r(t) {
  return new W("unsupported zone", `the zone "${t.name}" is not supported`);
}
function mn(t) {
  return (t.weekData === null && (t.weekData = Gt(t.c)), t.weekData);
}
function pn(t) {
  return (
    t.localWeekData === null &&
      (t.localWeekData = Gt(t.c, t.loc.getMinDaysInFirstWeek(), t.loc.getStartOfWeek())),
    t.localWeekData
  );
}
function Ge(t, e) {
  let r = { ts: t.ts, zone: t.zone, c: t.c, o: t.o, loc: t.loc, invalid: t.invalid };
  return new I({ ...r, ...e, old: r });
}
function Us(t, e, r) {
  let n = t - e * 60 * 1e3,
    s = r.offset(n);
  if (e === s) return [n, e];
  n -= (s - e) * 60 * 1e3;
  let i = r.offset(n);
  return s === i ? [n, s] : [t - Math.min(s, i) * 60 * 1e3, Math.max(s, i)];
}
function Tr(t, e) {
  t += e * 60 * 1e3;
  let r = new Date(t);
  return {
    year: r.getUTCFullYear(),
    month: r.getUTCMonth() + 1,
    day: r.getUTCDate(),
    hour: r.getUTCHours(),
    minute: r.getUTCMinutes(),
    second: r.getUTCSeconds(),
    millisecond: r.getUTCMilliseconds(),
  };
}
function kr(t, e, r) {
  return Us(st(t), e, r);
}
function Zs(t, e) {
  let r = t.o,
    n = t.c.year + Math.trunc(e.years),
    s = t.c.month + Math.trunc(e.months) + Math.trunc(e.quarters) * 3,
    i = {
      ...t.c,
      year: n,
      month: s,
      day: Math.min(t.c.day, ot(n, s)) + Math.trunc(e.days) + Math.trunc(e.weeks) * 7,
    },
    a = N.fromObject({
      years: e.years - Math.trunc(e.years),
      quarters: e.quarters - Math.trunc(e.quarters),
      months: e.months - Math.trunc(e.months),
      weeks: e.weeks - Math.trunc(e.weeks),
      days: e.days - Math.trunc(e.days),
      hours: e.hours,
      minutes: e.minutes,
      seconds: e.seconds,
      milliseconds: e.milliseconds,
    }).as("milliseconds"),
    o = st(i),
    [l, u] = Us(o, r, t.zone);
  return (a !== 0 && ((l += a), (u = t.zone.offset(l))), { ts: l, o: u });
}
function Xt(t, e, r, n, s, i) {
  let { setZone: a, zone: o } = r;
  if ((t && Object.keys(t).length !== 0) || e) {
    let l = e || o,
      u = I.fromObject(t, { ...r, zone: l, specificOffset: i });
    return a ? u : u.setZone(o);
  } else return I.invalid(new W("unparsable", `the input "${s}" can't be parsed as ${n}`));
}
function br(t, e, r = !0) {
  return t.isValid
    ? L.create(O.create("en-US"), { allowZ: r, forceSimple: !0 }).formatDateTimeFromString(t, e)
    : null;
}
function yn(t, e) {
  let r = t.c.year > 9999 || t.c.year < 0,
    n = "";
  return (
    r && t.c.year >= 0 && (n += "+"),
    (n += M(t.c.year, r ? 6 : 4)),
    e
      ? ((n += "-"), (n += M(t.c.month)), (n += "-"), (n += M(t.c.day)))
      : ((n += M(t.c.month)), (n += M(t.c.day))),
    n
  );
}
function Ps(t, e, r, n, s, i) {
  let a = M(t.c.hour);
  return (
    e
      ? ((a += ":"),
        (a += M(t.c.minute)),
        (t.c.millisecond !== 0 || t.c.second !== 0 || !r) && (a += ":"))
      : (a += M(t.c.minute)),
    (t.c.millisecond !== 0 || t.c.second !== 0 || !r) &&
      ((a += M(t.c.second)),
      (t.c.millisecond !== 0 || !n) && ((a += "."), (a += M(t.c.millisecond, 3)))),
    s &&
      (t.isOffsetFixed && t.offset === 0 && !i
        ? (a += "Z")
        : t.o < 0
          ? ((a += "-"),
            (a += M(Math.trunc(-t.o / 60))),
            (a += ":"),
            (a += M(Math.trunc(-t.o % 60))))
          : ((a += "+"),
            (a += M(Math.trunc(t.o / 60))),
            (a += ":"),
            (a += M(Math.trunc(t.o % 60))))),
    i && (a += "[" + t.zone.ianaName + "]"),
    a
  );
}
var Hs = { month: 1, day: 1, hour: 0, minute: 0, second: 0, millisecond: 0 },
  No = { weekNumber: 1, weekday: 1, hour: 0, minute: 0, second: 0, millisecond: 0 },
  Co = { ordinal: 1, hour: 0, minute: 0, second: 0, millisecond: 0 },
  Gs = ["year", "month", "day", "hour", "minute", "second", "millisecond"],
  Ao = ["weekYear", "weekNumber", "weekday", "hour", "minute", "second", "millisecond"],
  Fo = ["year", "ordinal", "hour", "minute", "second", "millisecond"];
function Wo(t) {
  let e = {
    year: "year",
    years: "year",
    month: "month",
    months: "month",
    day: "day",
    days: "day",
    hour: "hour",
    hours: "hour",
    minute: "minute",
    minutes: "minute",
    quarter: "quarter",
    quarters: "quarter",
    second: "second",
    seconds: "second",
    millisecond: "millisecond",
    milliseconds: "millisecond",
    weekday: "weekday",
    weekdays: "weekday",
    weeknumber: "weekNumber",
    weeksnumber: "weekNumber",
    weeknumbers: "weekNumber",
    weekyear: "weekYear",
    weekyears: "weekYear",
    ordinal: "ordinal",
  }[t.toLowerCase()];
  if (!e) throw new nt(t);
  return e;
}
function zs(t) {
  switch (t.toLowerCase()) {
    case "localweekday":
    case "localweekdays":
      return "localWeekday";
    case "localweeknumber":
    case "localweeknumbers":
      return "localWeekNumber";
    case "localweekyear":
    case "localweekyears":
      return "localWeekYear";
    default:
      return Wo(t);
  }
}
function Vs(t, e) {
  let r = te(e.zone, S.defaultZone),
    n = O.fromObject(e),
    s = S.now(),
    i,
    a;
  if (v(t.year)) i = s;
  else {
    for (let u of Gs) v(t[u]) && (t[u] = Hs[u]);
    let o = Kr(t) || Qr(t);
    if (o) return I.invalid(o);
    let l = r.offset(s);
    [i, a] = kr(t, l, r);
  }
  return new I({ ts: i, zone: r, loc: n, o: a });
}
function $s(t, e, r) {
  let n = v(r.round) ? !0 : r.round,
    s = (a, o) => (
      (a = it(a, n || r.calendary ? 0 : 2, !0)),
      e.loc.clone(r).relFormatter(r).format(a, o)
    ),
    i = (a) =>
      r.calendary
        ? e.hasSame(t, a)
          ? 0
          : e.startOf(a).diff(t.startOf(a), a).get(a)
        : e.diff(t, a).get(a);
  if (r.unit) return s(i(r.unit), r.unit);
  for (let a of r.units) {
    let o = i(a);
    if (Math.abs(o) >= 1) return s(o, a);
  }
  return s(t > e ? -0 : 0, r.units[r.units.length - 1]);
}
function js(t) {
  let e = {},
    r;
  return (
    t.length > 0 && typeof t[t.length - 1] == "object"
      ? ((e = t[t.length - 1]), (r = Array.from(t).slice(0, t.length - 1)))
      : (r = Array.from(t)),
    [e, r]
  );
}
var I = class t {
  constructor(e) {
    let r = e.zone || S.defaultZone,
      n =
        e.invalid ||
        (Number.isNaN(e.ts) ? new W("invalid input") : null) ||
        (r.isValid ? null : _r(r));
    this.ts = v(e.ts) ? S.now() : e.ts;
    let s = null,
      i = null;
    if (!n)
      if (e.old && e.old.ts === this.ts && e.old.zone.equals(r)) [s, i] = [e.old.c, e.old.o];
      else {
        let o = r.offset(this.ts);
        ((s = Tr(this.ts, o)),
          (n = Number.isNaN(s.year) ? new W("invalid input") : null),
          (s = n ? null : s),
          (i = n ? null : o));
      }
    ((this._zone = r),
      (this.loc = e.loc || O.create()),
      (this.invalid = n),
      (this.weekData = null),
      (this.localWeekData = null),
      (this.c = s),
      (this.o = i),
      (this.isLuxonDateTime = !0));
  }
  static now() {
    return new t({});
  }
  static local() {
    let [e, r] = js(arguments),
      [n, s, i, a, o, l, u] = r;
    return Vs({ year: n, month: s, day: i, hour: a, minute: o, second: l, millisecond: u }, e);
  }
  static utc() {
    let [e, r] = js(arguments),
      [n, s, i, a, o, l, u] = r;
    return (
      (e.zone = F.utcInstance),
      Vs({ year: n, month: s, day: i, hour: a, minute: o, second: l, millisecond: u }, e)
    );
  }
  static fromJSDate(e, r = {}) {
    let n = ns(e) ? e.valueOf() : NaN;
    if (Number.isNaN(n)) return t.invalid("invalid input");
    let s = te(r.zone, S.defaultZone);
    return s.isValid ? new t({ ts: n, zone: s, loc: O.fromObject(r) }) : t.invalid(_r(s));
  }
  static fromMillis(e, r = {}) {
    if (oe(e))
      return e < -Rs || e > Rs
        ? t.invalid("Timestamp out of range")
        : new t({ ts: e, zone: te(r.zone, S.defaultZone), loc: O.fromObject(r) });
    throw new C(
      `fromMillis requires a numerical input, but received a ${typeof e} with value ${e}`,
    );
  }
  static fromSeconds(e, r = {}) {
    if (oe(e)) return new t({ ts: e * 1e3, zone: te(r.zone, S.defaultZone), loc: O.fromObject(r) });
    throw new C("fromSeconds requires a numerical input");
  }
  static fromObject(e, r = {}) {
    e = e || {};
    let n = te(r.zone, S.defaultZone);
    if (!n.isValid) return t.invalid(_r(n));
    let s = O.fromObject(r),
      i = lt(e, zs),
      { minDaysInFirstWeek: a, startOfWeek: o } = Jr(i, s),
      l = S.now(),
      u = v(r.specificOffset) ? n.offset(l) : r.specificOffset,
      d = !v(i.ordinal),
      g = !v(i.year),
      D = !v(i.month) || !v(i.day),
      w = g || D,
      A = i.weekYear || i.weekNumber;
    if ((w || d) && A)
      throw new Q("Can't mix weekYear/weekNumber units with year/month/day or ordinals");
    if (D && d) throw new Q("Can't mix ordinal dates with month/day");
    let Ye = A || (i.weekday && !w),
      se,
      qe,
      gt = Tr(l, u);
    Ye
      ? ((se = Ao), (qe = No), (gt = Gt(gt, a, o)))
      : d
        ? ((se = Fo), (qe = Co), (gt = vr(gt)))
        : ((se = Gs), (qe = Hs));
    let vn = !1;
    for (let vt of se) {
      let Qs = i[vt];
      v(Qs) ? (vn ? (i[vt] = qe[vt]) : (i[vt] = gt[vt])) : (vn = !0);
    }
    let qs = Ye ? es(i, a, o) : d ? ts(i) : Kr(i),
      wn = qs || Qr(i);
    if (wn) return t.invalid(wn);
    let Bs = Ye ? qr(i, a, o) : d ? Br(i) : i,
      [Js, Ks] = kr(Bs, u, n),
      Sr = new t({ ts: Js, zone: n, o: Ks, loc: s });
    return i.weekday && w && e.weekday !== Sr.weekday
      ? t.invalid(
          "mismatched weekday",
          `you can't specify both a weekday of ${i.weekday} and a date of ${Sr.toISO()}`,
        )
      : Sr;
  }
  static fromISO(e, r = {}) {
    let [n, s] = vs(e);
    return Xt(n, s, r, "ISO 8601", e);
  }
  static fromRFC2822(e, r = {}) {
    let [n, s] = ws(e);
    return Xt(n, s, r, "RFC 2822", e);
  }
  static fromHTTP(e, r = {}) {
    let [n, s] = _s(e);
    return Xt(n, s, r, "HTTP", r);
  }
  static fromFormat(e, r, n = {}) {
    if (v(e) || v(r)) throw new C("fromFormat requires an input string and a format");
    let { locale: s = null, numberingSystem: i = null } = n,
      a = O.fromOpts({ locale: s, numberingSystem: i, defaultToEN: !0 }),
      [o, l, u, d] = Ls(a, e, r);
    return d ? t.invalid(d) : Xt(o, l, n, `format ${r}`, e, u);
  }
  static fromString(e, r, n = {}) {
    return t.fromFormat(e, r, n);
  }
  static fromSQL(e, r = {}) {
    let [n, s] = ks(e);
    return Xt(n, s, r, "SQL", e);
  }
  static invalid(e, r = null) {
    if (!e) throw new C("need to specify a reason the DateTime is invalid");
    let n = e instanceof W ? e : new W(e, r);
    if (S.throwOnInvalid) throw new ar(n);
    return new t({ invalid: n });
  }
  static isDateTime(e) {
    return (e && e.isLuxonDateTime) || !1;
  }
  static parseFormatForOpts(e, r = {}) {
    let n = fn(e, O.fromObject(r));
    return n ? n.map((s) => (s ? s.val : null)).join("") : null;
  }
  static expandFormat(e, r = {}) {
    return cn(L.parseFormat(e), O.fromObject(r))
      .map((s) => s.val)
      .join("");
  }
  get(e) {
    return this[e];
  }
  get isValid() {
    return this.invalid === null;
  }
  get invalidReason() {
    return this.invalid ? this.invalid.reason : null;
  }
  get invalidExplanation() {
    return this.invalid ? this.invalid.explanation : null;
  }
  get locale() {
    return this.isValid ? this.loc.locale : null;
  }
  get numberingSystem() {
    return this.isValid ? this.loc.numberingSystem : null;
  }
  get outputCalendar() {
    return this.isValid ? this.loc.outputCalendar : null;
  }
  get zone() {
    return this._zone;
  }
  get zoneName() {
    return this.isValid ? this.zone.name : null;
  }
  get year() {
    return this.isValid ? this.c.year : NaN;
  }
  get quarter() {
    return this.isValid ? Math.ceil(this.c.month / 3) : NaN;
  }
  get month() {
    return this.isValid ? this.c.month : NaN;
  }
  get day() {
    return this.isValid ? this.c.day : NaN;
  }
  get hour() {
    return this.isValid ? this.c.hour : NaN;
  }
  get minute() {
    return this.isValid ? this.c.minute : NaN;
  }
  get second() {
    return this.isValid ? this.c.second : NaN;
  }
  get millisecond() {
    return this.isValid ? this.c.millisecond : NaN;
  }
  get weekYear() {
    return this.isValid ? mn(this).weekYear : NaN;
  }
  get weekNumber() {
    return this.isValid ? mn(this).weekNumber : NaN;
  }
  get weekday() {
    return this.isValid ? mn(this).weekday : NaN;
  }
  get isWeekend() {
    return this.isValid && this.loc.getWeekendDays().includes(this.weekday);
  }
  get localWeekday() {
    return this.isValid ? pn(this).weekday : NaN;
  }
  get localWeekNumber() {
    return this.isValid ? pn(this).weekNumber : NaN;
  }
  get localWeekYear() {
    return this.isValid ? pn(this).weekYear : NaN;
  }
  get ordinal() {
    return this.isValid ? vr(this.c).ordinal : NaN;
  }
  get monthShort() {
    return this.isValid ? pe.months("short", { locObj: this.loc })[this.month - 1] : null;
  }
  get monthLong() {
    return this.isValid ? pe.months("long", { locObj: this.loc })[this.month - 1] : null;
  }
  get weekdayShort() {
    return this.isValid ? pe.weekdays("short", { locObj: this.loc })[this.weekday - 1] : null;
  }
  get weekdayLong() {
    return this.isValid ? pe.weekdays("long", { locObj: this.loc })[this.weekday - 1] : null;
  }
  get offset() {
    return this.isValid ? +this.o : NaN;
  }
  get offsetNameShort() {
    return this.isValid
      ? this.zone.offsetName(this.ts, { format: "short", locale: this.locale })
      : null;
  }
  get offsetNameLong() {
    return this.isValid
      ? this.zone.offsetName(this.ts, { format: "long", locale: this.locale })
      : null;
  }
  get isOffsetFixed() {
    return this.isValid ? this.zone.isUniversal : null;
  }
  get isInDST() {
    return this.isOffsetFixed
      ? !1
      : this.offset > this.set({ month: 1, day: 1 }).offset ||
          this.offset > this.set({ month: 5 }).offset;
  }
  getPossibleOffsets() {
    if (!this.isValid || this.isOffsetFixed) return [this];
    let e = 864e5,
      r = 6e4,
      n = st(this.c),
      s = this.zone.offset(n - e),
      i = this.zone.offset(n + e),
      a = this.zone.offset(n - s * r),
      o = this.zone.offset(n - i * r);
    if (a === o) return [this];
    let l = n - a * r,
      u = n - o * r,
      d = Tr(l, a),
      g = Tr(u, o);
    return d.hour === g.hour &&
      d.minute === g.minute &&
      d.second === g.second &&
      d.millisecond === g.millisecond
      ? [Ge(this, { ts: l }), Ge(this, { ts: u })]
      : [this];
  }
  get isInLeapYear() {
    return Ue(this.year);
  }
  get daysInMonth() {
    return ot(this.year, this.month);
  }
  get daysInYear() {
    return this.isValid ? be(this.year) : NaN;
  }
  get weeksInWeekYear() {
    return this.isValid ? je(this.weekYear) : NaN;
  }
  get weeksInLocalWeekYear() {
    return this.isValid
      ? je(this.localWeekYear, this.loc.getMinDaysInFirstWeek(), this.loc.getStartOfWeek())
      : NaN;
  }
  resolvedLocaleOptions(e = {}) {
    let {
      locale: r,
      numberingSystem: n,
      calendar: s,
    } = L.create(this.loc.clone(e), e).resolvedOptions(this);
    return { locale: r, numberingSystem: n, outputCalendar: s };
  }
  toUTC(e = 0, r = {}) {
    return this.setZone(F.instance(e), r);
  }
  toLocal() {
    return this.setZone(S.defaultZone);
  }
  setZone(e, { keepLocalTime: r = !1, keepCalendarTime: n = !1 } = {}) {
    if (((e = te(e, S.defaultZone)), e.equals(this.zone))) return this;
    if (e.isValid) {
      let s = this.ts;
      if (r || n) {
        let i = e.offset(this.ts),
          a = this.toObject();
        [s] = kr(a, i, e);
      }
      return Ge(this, { ts: s, zone: e });
    } else return t.invalid(_r(e));
  }
  reconfigure({ locale: e, numberingSystem: r, outputCalendar: n } = {}) {
    let s = this.loc.clone({ locale: e, numberingSystem: r, outputCalendar: n });
    return Ge(this, { loc: s });
  }
  setLocale(e) {
    return this.reconfigure({ locale: e });
  }
  set(e) {
    if (!this.isValid) return this;
    let r = lt(e, zs),
      { minDaysInFirstWeek: n, startOfWeek: s } = Jr(r, this.loc),
      i = !v(r.weekYear) || !v(r.weekNumber) || !v(r.weekday),
      a = !v(r.ordinal),
      o = !v(r.year),
      l = !v(r.month) || !v(r.day),
      u = o || l,
      d = r.weekYear || r.weekNumber;
    if ((u || a) && d)
      throw new Q("Can't mix weekYear/weekNumber units with year/month/day or ordinals");
    if (l && a) throw new Q("Can't mix ordinal dates with month/day");
    let g;
    i
      ? (g = qr({ ...Gt(this.c, n, s), ...r }, n, s))
      : v(r.ordinal)
        ? ((g = { ...this.toObject(), ...r }),
          v(r.day) && (g.day = Math.min(ot(g.year, g.month), g.day)))
        : (g = Br({ ...vr(this.c), ...r }));
    let [D, w] = kr(g, this.o, this.zone);
    return Ge(this, { ts: D, o: w });
  }
  plus(e) {
    if (!this.isValid) return this;
    let r = N.fromDurationLike(e);
    return Ge(this, Zs(this, r));
  }
  minus(e) {
    if (!this.isValid) return this;
    let r = N.fromDurationLike(e).negate();
    return Ge(this, Zs(this, r));
  }
  startOf(e, { useLocaleWeeks: r = !1 } = {}) {
    if (!this.isValid) return this;
    let n = {},
      s = N.normalizeUnit(e);
    switch (s) {
      case "years":
        n.month = 1;
      case "quarters":
      case "months":
        n.day = 1;
      case "weeks":
      case "days":
        n.hour = 0;
      case "hours":
        n.minute = 0;
      case "minutes":
        n.second = 0;
      case "seconds":
        n.millisecond = 0;
        break;
      case "milliseconds":
        break;
    }
    if (s === "weeks")
      if (r) {
        let i = this.loc.getStartOfWeek(),
          { weekday: a } = this;
        (a < i && (n.weekNumber = this.weekNumber - 1), (n.weekday = i));
      } else n.weekday = 1;
    if (s === "quarters") {
      let i = Math.ceil(this.month / 3);
      n.month = (i - 1) * 3 + 1;
    }
    return this.set(n);
  }
  endOf(e, r) {
    return this.isValid
      ? this.plus({ [e]: 1 })
          .startOf(e, r)
          .minus(1)
      : this;
  }
  toFormat(e, r = {}) {
    return this.isValid
      ? L.create(this.loc.redefaultToEN(r)).formatDateTimeFromString(this, e)
      : hn;
  }
  toLocaleString(e = we, r = {}) {
    return this.isValid ? L.create(this.loc.clone(r), e).formatDateTime(this) : hn;
  }
  toLocaleParts(e = {}) {
    return this.isValid ? L.create(this.loc.clone(e), e).formatDateTimeParts(this) : [];
  }
  toISO({
    format: e = "extended",
    suppressSeconds: r = !1,
    suppressMilliseconds: n = !1,
    includeOffset: s = !0,
    extendedZone: i = !1,
  } = {}) {
    if (!this.isValid) return null;
    let a = e === "extended",
      o = yn(this, a);
    return ((o += "T"), (o += Ps(this, a, r, n, s, i)), o);
  }
  toISODate({ format: e = "extended" } = {}) {
    return this.isValid ? yn(this, e === "extended") : null;
  }
  toISOWeekDate() {
    return br(this, "kkkk-'W'WW-c");
  }
  toISOTime({
    suppressMilliseconds: e = !1,
    suppressSeconds: r = !1,
    includeOffset: n = !0,
    includePrefix: s = !1,
    extendedZone: i = !1,
    format: a = "extended",
  } = {}) {
    return this.isValid ? (s ? "T" : "") + Ps(this, a === "extended", r, e, n, i) : null;
  }
  toRFC2822() {
    return br(this, "EEE, dd LLL yyyy HH:mm:ss ZZZ", !1);
  }
  toHTTP() {
    return br(this.toUTC(), "EEE, dd LLL yyyy HH:mm:ss 'GMT'");
  }
  toSQLDate() {
    return this.isValid ? yn(this, !0) : null;
  }
  toSQLTime({ includeOffset: e = !0, includeZone: r = !1, includeOffsetSpace: n = !0 } = {}) {
    let s = "HH:mm:ss.SSS";
    return ((r || e) && (n && (s += " "), r ? (s += "z") : e && (s += "ZZ")), br(this, s, !0));
  }
  toSQL(e = {}) {
    return this.isValid ? `${this.toSQLDate()} ${this.toSQLTime(e)}` : null;
  }
  toString() {
    return this.isValid ? this.toISO() : hn;
  }
  [Symbol.for("nodejs.util.inspect.custom")]() {
    return this.isValid
      ? `DateTime { ts: ${this.toISO()}, zone: ${this.zone.name}, locale: ${this.locale} }`
      : `DateTime { Invalid, reason: ${this.invalidReason} }`;
  }
  valueOf() {
    return this.toMillis();
  }
  toMillis() {
    return this.isValid ? this.ts : NaN;
  }
  toSeconds() {
    return this.isValid ? this.ts / 1e3 : NaN;
  }
  toUnixInteger() {
    return this.isValid ? Math.floor(this.ts / 1e3) : NaN;
  }
  toJSON() {
    return this.toISO();
  }
  toBSON() {
    return this.toJSDate();
  }
  toObject(e = {}) {
    if (!this.isValid) return {};
    let r = { ...this.c };
    return (
      e.includeConfig &&
        ((r.outputCalendar = this.outputCalendar),
        (r.numberingSystem = this.loc.numberingSystem),
        (r.locale = this.loc.locale)),
      r
    );
  }
  toJSDate() {
    return new Date(this.isValid ? this.ts : NaN);
  }
  diff(e, r = "milliseconds", n = {}) {
    if (!this.isValid || !e.isValid) return N.invalid("created by diffing an invalid DateTime");
    let s = { locale: this.locale, numberingSystem: this.numberingSystem, ...n },
      i = ss(r).map(N.normalizeUnit),
      a = e.valueOf() > this.valueOf(),
      o = a ? this : e,
      l = a ? e : this,
      u = Ds(o, l, i, s);
    return a ? u.negate() : u;
  }
  diffNow(e = "milliseconds", r = {}) {
    return this.diff(t.now(), e, r);
  }
  until(e) {
    return this.isValid ? me.fromDateTimes(this, e) : this;
  }
  hasSame(e, r, n) {
    if (!this.isValid) return !1;
    let s = e.valueOf(),
      i = this.setZone(e.zone, { keepLocalTime: !0 });
    return i.startOf(r, n) <= s && s <= i.endOf(r, n);
  }
  equals(e) {
    return (
      this.isValid &&
      e.isValid &&
      this.valueOf() === e.valueOf() &&
      this.zone.equals(e.zone) &&
      this.loc.equals(e.loc)
    );
  }
  toRelative(e = {}) {
    if (!this.isValid) return null;
    let r = e.base || t.fromObject({}, { zone: this.zone }),
      n = e.padding ? (this < r ? -e.padding : e.padding) : 0,
      s = ["years", "months", "days", "hours", "minutes", "seconds"],
      i = e.unit;
    return (
      Array.isArray(e.unit) && ((s = e.unit), (i = void 0)),
      $s(r, this.plus(n), { ...e, numeric: "always", units: s, unit: i })
    );
  }
  toRelativeCalendar(e = {}) {
    return this.isValid
      ? $s(e.base || t.fromObject({}, { zone: this.zone }), this, {
          ...e,
          numeric: "auto",
          units: ["years", "months", "days"],
          calendary: !0,
        })
      : null;
  }
  static min(...e) {
    if (!e.every(t.isDateTime)) throw new C("min requires all arguments be DateTimes");
    return Xr(e, (r) => r.valueOf(), Math.min);
  }
  static max(...e) {
    if (!e.every(t.isDateTime)) throw new C("max requires all arguments be DateTimes");
    return Xr(e, (r) => r.valueOf(), Math.max);
  }
  static fromFormatExplain(e, r, n = {}) {
    let { locale: s = null, numberingSystem: i = null } = n,
      a = O.fromOpts({ locale: s, numberingSystem: i, defaultToEN: !0 });
    return dn(a, e, r);
  }
  static fromStringExplain(e, r, n = {}) {
    return t.fromFormatExplain(e, r, n);
  }
  static get DATE_SHORT() {
    return we;
  }
  static get DATE_MED() {
    return St;
  }
  static get DATE_MED_WITH_WEEKDAY() {
    return Cr;
  }
  static get DATE_FULL() {
    return Et;
  }
  static get DATE_HUGE() {
    return Ot;
  }
  static get TIME_SIMPLE() {
    return It;
  }
  static get TIME_WITH_SECONDS() {
    return Dt;
  }
  static get TIME_WITH_SHORT_OFFSET() {
    return Mt;
  }
  static get TIME_WITH_LONG_OFFSET() {
    return Nt;
  }
  static get TIME_24_SIMPLE() {
    return Ct;
  }
  static get TIME_24_WITH_SECONDS() {
    return At;
  }
  static get TIME_24_WITH_SHORT_OFFSET() {
    return Ft;
  }
  static get TIME_24_WITH_LONG_OFFSET() {
    return Wt;
  }
  static get DATETIME_SHORT() {
    return Lt;
  }
  static get DATETIME_SHORT_WITH_SECONDS() {
    return Rt;
  }
  static get DATETIME_MED() {
    return Zt;
  }
  static get DATETIME_MED_WITH_SECONDS() {
    return Pt;
  }
  static get DATETIME_MED_WITH_WEEKDAY() {
    return Ar;
  }
  static get DATETIME_FULL() {
    return zt;
  }
  static get DATETIME_FULL_WITH_SECONDS() {
    return Vt;
  }
  static get DATETIME_HUGE() {
    return $t;
  }
  static get DATETIME_HUGE_WITH_SECONDS() {
    return jt;
  }
};
function yt(t) {
  if (I.isDateTime(t)) return t;
  if (t && t.valueOf && oe(t.valueOf())) return I.fromJSDate(t);
  if (t && typeof t == "object") return I.fromObject(t);
  throw new C(`Unknown datetime argument: ${t}, of type ${typeof t}`);
}
var xr = c
    .string()
    .regex(
      /^([+-]?\d+(?:\.\d+)?)(%|px)?$/,
      "Not a valid length value. Must be of format '10px' or '10%'.",
    ),
  Ys = c
    .string()
    .min(2, "Name must be at least 2 characters.")
    .max(28, "Name cannot exceed 28 characters.")
    .regex(
      /^[a-z0-9][a-z0-9-_]*$/,
      "Only lowercase letters, numbers, and the characters - and _ are allowed.",
    ),
  Ro = c
    .string()
    .regex(
      /^[0-9]{1,4}\.[0-9]{1,4}\.[0-9]{1,4}$/,
      'Version must be in the format "x.y.z" (e.g. "1.0.0").',
    ),
  Zo = c.object({
    name: Ys,
    htmlPath: c
      .string()
      .refine((t) => t.endsWith(".html"), {
        message: 'Must be a valid HTML file path (e.g. "path/to/widget.html").',
      }),
    zOrder: c.enum(["normal", "top_most", "bottom_most"]),
    shownInTaskbar: c.boolean(),
    focused: c.boolean(),
    resizable: c.boolean(),
    transparent: c.boolean(),
    includeFiles: c.array(c.string()).default([]),
    caching: c.object({
      defaultDuration: c.number(),
      rules: c.array(c.object({ urlRegex: c.string(), duration: c.number() })),
    }),
    privileges: c.object({
      shellCommands: c.array(c.object({ program: c.string(), argsRegex: c.string() })),
    }),
    presets: c.array(
      c.object({
        name: c.string(),
        anchor: c.enum([
          "top_left",
          "top_center",
          "top_right",
          "center_left",
          "center",
          "center_right",
          "bottom_left",
          "bottom_center",
          "bottom_right",
        ]),
        offsetX: xr,
        offsetY: xr,
        width: xr,
        height: xr,
        monitorSelection: c.union([
          c.object({ type: c.literal("all") }),
          c.object({ type: c.literal("primary") }),
          c.object({ type: c.literal("secondary") }),
          c.object({ type: c.literal("index"), match: c.number() }),
          c.object({ type: c.literal("name"), match: c.string() }),
        ]),
        dockToEdge: c.object({
          enabled: c.boolean(),
          edge: c.enum(["top", "right", "bottom", "left"]).nullable(),
          windowMargin: c.string(),
        }),
      }),
    ),
  }),
  Cc = c.object({
    name: Ys,
    version: Ro,
    description: c.string().max(1e3, "Description cannot exceed 1000 characters."),
    tags: c.array(c.string()).max(10, "At most 10 tags are allowed."),
    previewImages: c
      .array(
        c
          .string()
          .refine((t) => !t.startsWith("http"), {
            message: "Preview image must be a file within the widget pack.",
          })
          .refine((t) => !t.includes(":\\") && !t.startsWith("/"), {
            message: 'Preview image must be a relative file path (e.g. "resources/preview.png")',
          }),
      )
      .min(1, "At least one preview image is required.")
      .max(6, "At most 6 preview images are allowed."),
    widgets: c.array(Zo),
    repositoryUrl: c.string().url().or(c.literal("")),
  });
function Po(t) {
  function e(a, o, ...l) {
    let u = new Date(),
      d = `${u.getHours().toString().padStart(2, "0")}:${u.getMinutes().toString().padStart(2, "0")}:${u.getSeconds().toString().padStart(2, "0")}:${u.getMilliseconds().toString().padStart(3, "0")}`;
    console[a](
      `%c[Zebar] %c${d}%c${t ? ` (${t})` : ""} %c${o}`,
      "color: #4ade80",
      "color: #f5f9b4",
      "color: #d0b4f9",
      "color: inherit",
      ...l,
    );
  }
  function r(a, ...o) {
    e("log", a, ...o);
  }
  function n(a, ...o) {
    e("log", a, ...o);
  }
  function s(a, ...o) {
    e("warn", a, ...o);
  }
  function i(a, ...o) {
    e("error", a, ...o);
  }
  return { debug: r, info: n, warn: s, error: i };
}
var gn = Po(),
  zo = {
    startWidget: Vo,
    startWidgetPreset: $o,
    listenProvider: jo,
    unlistenProvider: Uo,
    callProviderFunction: Ho,
    setAlwaysOnTop: Go,
    setSkipTaskbar: Yo,
    shellExec: qo,
    shellSpawn: Bo,
    shellWrite: Jo,
    shellKill: Ko,
  };
function Vo(t, e, r, n) {
  return ne("start_widget", { packId: t, widgetName: e, placement: r, isPreview: n });
}
function $o(t, e, r, n) {
  return ne("start_widget_preset", { packId: t, widgetName: e, presetName: r, isPreview: n });
}
function jo(t) {
  return ne("listen_provider", t);
}
function Uo(t) {
  return ne("unlisten_provider", { configHash: t });
}
function Ho(t, e) {
  return ne("call_provider_function", { configHash: t, function: e });
}
function Go() {
  return ne("set_always_on_top");
}
function Yo(t) {
  return ne("set_skip_taskbar", { skip: t });
}
function qo(t, e = [], r = {}) {
  return ne("shell_exec", { program: t, args: e, options: r });
}
function Bo(t, e = [], r = {}) {
  return ne("shell_spawn", { program: t, args: e, options: r });
}
function Jo(t, e) {
  return ne("shell_write", { processId: t, buffer: e });
}
function Ko(t) {
  return ne("shell_kill", { processId: t });
}
async function ne(t, e) {
  gn.info(`Calling '${t}' with args:`, e ?? {});
  try {
    let r = await xt(t, e);
    return (gn.info(`Response for calling '${t}':`, r), r);
  } catch (r) {
    throw (gn.error(`Command '${t}' failed: ${r}`), new Error(`Command '${t}' failed: ${r}`));
  }
}
async function Qo(t, e, r) {
  return await zo.shellExec(t, e, r);
}
var Pc = c.object({ type: c.literal("audio") });
var Vc = c.object({
  type: c.literal("battery"),
  refreshInterval: c.coerce.number().default(60 * 1e3),
});
var jc = c.object({ type: c.literal("cpu"), refreshInterval: c.coerce.number().default(5 * 1e3) });
var Gc = c.object({
  type: c.literal("date"),
  refreshInterval: c.coerce.number().default(1e3),
  timezone: c.string().default("local"),
  locale: c.string().optional(),
  formatting: c.string().default("EEE	d MMM t"),
});
var qc = c.object({ type: c.literal("glazewm") });
var Jc = c.object({
  type: c.literal("host"),
  refreshInterval: c.coerce.number().default(60 * 1e3),
});
var Qc = c.object({
  type: c.literal("ip"),
  refreshInterval: c.coerce.number().default(3600 * 1e3),
});
var ed = c.object({ type: c.literal("keyboard"), refreshInterval: c.coerce.number().default(1e3) });
var rd = c.object({ type: c.literal("komorebi") });
var sd = c.object({ type: c.literal("media") });
var ad = c.object({
  type: c.literal("memory"),
  refreshInterval: c.coerce.number().default(5 * 1e3),
});
var ld = c.object({
  type: c.literal("network"),
  refreshInterval: c.coerce.number().default(5 * 1e3),
});
var cd = c.object({
  type: c.literal("weather"),
  latitude: c.coerce.number().optional(),
  longitude: c.coerce.number().optional(),
  refreshInterval: c.coerce.number().default(3600 * 1e3),
});
var fd = c.object({
  type: c.literal("disk"),
  refreshInterval: c.coerce.number().default(60 * 1e3),
});
var md = c.object({ type: c.literal("systray") });
export { Qo as shellExec };
