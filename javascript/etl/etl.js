if (module) {
  module.exports = transform_schema;
}

function transform_schema(old_schema) {
  return Object.keys(old_schema).reduce(create_schema_transformer(old_schema), {});
}

function create_schema_transformer(old_schema) {
  return function(new_schema, point_value) {
    var insert_points_into_schema;
    point_value = Number(point_value);
    insert_points_into_schema = function (schema, word) { // fn express'n doesn't get hoisted
      schema[word.toLowerCase()] = point_value;
      return schema;
    }
    return old_schema[point_value].reduce(insert_points_into_schema, new_schema);
  };
}
