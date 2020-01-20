module serialization;

import dyaml;
import std.json;
import std.stdio;
import std.traits;
import std.conv;

import gfm.math.vector;

struct Serialize
{
}

template SerializableAggregate(T)
{
	enum SerializableAggregate = (is(T == class) || is(T == struct)) && __traits(hasMember, T, "name");
}

auto deserialize(T)(string filePath, T t)
	if(SerializableAggregate!T)
{
	Loader.fromFile(filePath).load()[t.name].deserializeInto(t);
	return t;
}

void serialize(T)(string filePath, T t)
	if(SerializableAggregate!T)
{
	Node r;
	r.add(t.name, t.toYAMLNode());
	auto d = File(filePath, "w").lockingTextWriter;
	auto dm = dumper();
	dm.dump(d, r);
}

// https://github.com/forbjok/yamlserialized/blob/master/source/yamlserialized/serialization.d

/*
The MIT License (MIT)

Copyright (c) 2016 Kjartan F. Kvamme

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/

@safe:

/// Convert an array of type T to a D-YAML Node
Node toYAMLNode(T)(in ref T array) if (isArray!T) {
    alias ElementType = ForeachType!T;

    Node[] nodes;

    // Iterate each item in the array and add them to the array of nodes
    foreach(item; array) {
        static if (is(ElementType == struct)) {
            // This item is a struct
            nodes ~= item.toYAMLNode();
        }
        else static if (is(ElementType == class)) {
            // This item is a class - serialize it unless it is null
            if (item !is null) {
                nodes ~= item.toYAMLNode();
            }
        }
        else static if (isSomeString!ElementType) {
            nodes ~= Node(item.to!string);
        }
        else static if (isArray!ElementType) {
            // An array of arrays. Recursion time!
            nodes ~= item.toYAMLNode();
        }
        else {
            nodes ~= Node(item);
        }
    }

    return Node(nodes);
}

/// Convert an associative array of type T to a D-YAML Node
Node toYAMLNode(T)(in ref T associativeArray) if (isAssociativeArray!T) {
    alias KType = KeyType!T;
    alias VType = ValueType!T;

    Node[KType] items;

    // Iterate each item in the associative array
    foreach(key, value; associativeArray) {
        // Convert key to the correct type
        auto typedKey = key.to!KType;

        static if (is(VType == struct)) {
            // The value type is struct
            items[typedKey] = value.toYAMLNode();
        }
        else static if (is(VType == class)) {
            // The value is a class - serialize it unless it is null
            if (value !is null) {
                items[typedKey] = value.toYAMLNode();
            }
        }
        else static if (isAssociativeArray!VType) {
            /* The associative array's value type is another associative array type.
               It's recursion time. */
            items[typedKey] = value.toYAMLNode();
        }
        else static if (isSomeString!VType) {
            items[typedKey] = Node(value.to!string);
        }
        else {
            items[typedKey] = Node(value);
        }
    }

    return Node(items);
}

/// Convert a struct or class of type T to a D-YAML Node
Node toYAMLNode(T, bool SerializeFieldsOnly = true)(in ref T obj) if (is(T == struct) || is(T == class)) {
    enum fieldNames = FieldNameTuple!T;

    Node[string] nodes;

    foreach(fieldName; fieldNames) {
        auto field = __traits(getMember, obj, fieldName);
        alias FieldType = typeof(field);

		static if(SerializeFieldsOnly && !hasUDA!(__traits(getMember, T, fieldName), Serialize))
		{
		}
        else static if (isInstanceOf!(gfm.math.Vector, FieldType))
        {
            nodes[fieldName] = field.toYAMLNode!(FieldType, false);
        }
        else static if (is(FieldType == struct)) {
            // This field is a struct - recurse into it
            nodes[fieldName] = field.toYAMLNode();
        }
        else static if (is(FieldType == class)) {
            // This field is a class - recurse into it unless it is null
            if (field !is null) {
                nodes[fieldName] = field.toYAMLNode();
            }
        }
        else static if (isSomeChar!FieldType || isSomeString!FieldType) {
            // Because Node only seems to work with string strings (and not char[], etc), convert all string types to string
            nodes[fieldName] = Node(field.to!string);
        }
        else static if (isArray!FieldType) {
            // Field is an array
            nodes[fieldName] = field.toYAMLNode();
        }
        else static if (isAssociativeArray!FieldType) {
            // Field is an associative array
            nodes[fieldName] = field.toYAMLNode();
        }
        else {
            nodes[fieldName] = Node(field.to!FieldType);
		}
    }

    return Node(nodes);
}


/// Deserialize a D-YAML Node into an array T
void deserializeInto(T)(Node yamlNode, ref T array) if (isArray!T) {
    alias ElementType = ForeachType!T;

    uint i = 0;
    // Iterate each item in the array of nodes and add them to values, converting them to the actual type
    foreach(item; yamlNode.as!(Node[])) {
        static if (is(ElementType == struct)) {
            // This item is a struct - instantiate it
            ElementType newStruct;

            // ...deserialize into the new instance
            item.deserializeInto(newStruct);

            // ...and add it to the array
            array ~= newStruct;
        }
        else static if (is(ElementType == class)) {
            // The item type is class - create a new instance
            auto newClass = new ElementType();

            // ...deserialize into the new instance
            item.deserializeInto(newClass);

            // ...and add it to the array
            array ~= newClass;
        }
        else static if (isSomeString!ElementType) {
            array ~= item.as!string.to!ElementType;
        }
        else static if (isArray!ElementType) {
            // An array of arrays. Recursion time!
            ElementType subArray;

            item.deserializeInto(subArray);
            array ~= subArray;
        }
        else static if (isDynamicArray!ElementType) {
            array ~= item.as!ElementType;
        }
        else // static array
        {
            array[i] = item.as!ElementType;
        }
        i++;
    }
}

/// Deserialize a D-YAML Node into an associative array T
void deserializeInto(T)(Node yamlNode, ref T associativeArray) if (isAssociativeArray!T) {
    alias VType = ValueType!T;

    // Iterate each Pair in the Node
    foreach(pair; yamlNode.as!(Node.Pair[])) {
        auto key = pair.key.as!string.to!(KeyType!T);
        auto value = pair.value;

        static if (isAssociativeArray!VType) {
            /* The associative array's value type is another associative array type.
               It's recursion time. */

            if (key in associativeArray) {
                value.deserializeInto(associativeArray[key]);
            }
            else {
                VType subAssocArray;

                value.deserializeInto(subAssocArray);
                associativeArray[key] = subAssocArray;
            }
        }
        else static if (is(VType == struct)) {
            // The value type is a struct - instantiate it
            VType newStruct;

            // ...deserialize into the new instance
            value.deserializeInto(newStruct);

            // ...and add it to the associative array
            associativeArray[key] = newStruct;
        }
        else static if (is(VType == class)) {
            // The value type is class - create a new instance
            auto newClass = new VType();

            // ...deserialize into the new instance
            value.deserializeInto(newClass);

            // ...and add it to the associative array
            associativeArray[key] = newClass;
        }
        else {
            associativeArray[key] = value.as!VType;
        }
    }
}

/// Deserialize a D-YAML Node into a struct or class of type T
void deserializeInto(T, bool SerializeFieldsOnly = true)(Node yamlNode, ref T obj) 
if (is(T == struct) || is(T == class)) {
    enum fieldNames = FieldNameTuple!T;

    foreach(fieldName; fieldNames) {
        alias FieldType = typeof(__traits(getMember, obj, fieldName));
		
        if (!yamlNode.containsKey(fieldName)) {
            continue;
        }

        static if (SerializeFieldsOnly && !hasUDA!(__traits(getMember, T, fieldName), Serialize))
        {

        }
        else static if (isInstanceOf!(gfm.math.Vector, FieldType))
        {
            yamlNode[fieldName].deserializeInto!(FieldType, false)(__traits(getMember, obj, fieldName));
        }
        else static if (is(FieldType == struct)) {
            // This field is a struct - recurse into it
            yamlNode[fieldName].deserializeInto(__traits(getMember, obj, fieldName));
        }
        else static if (is(FieldType == class)) {
            // This field is a class - recurse into it unless it is null
            if (__traits(getMember, obj, fieldName) !is null) {
                yamlNode[fieldName].deserializeInto(__traits(getMember, obj, fieldName));
            }
        }
        else static if (isSomeChar!FieldType) {
            // Field is a char
            // Node.as!char fails for some reason, so we have to retrieve it as a string first
            // and then convert it to the correct type.
            __traits(getMember, obj, fieldName) = yamlNode[fieldName].as!string.to!FieldType;
        }
        else static if (isSomeString!FieldType) {
            // Field is a string
            __traits(getMember, obj, fieldName) = yamlNode[fieldName].as!string.to!FieldType;
        }
        else static if (isArray!FieldType) {
            // Field is an array
            yamlNode[fieldName].deserializeInto(__traits(getMember, obj, fieldName));
        }
        else static if (isAssociativeArray!FieldType) {
            // Field is an associative array
            yamlNode[fieldName].deserializeInto(__traits(getMember, obj, fieldName));
        }
        else static if (isIntegral!FieldType) {
            // Field is an integer
            if (yamlNode[fieldName].convertsTo!FieldType) {
                // If node contains an integer value, get it directly
                __traits(getMember, obj, fieldName) = yamlNode[fieldName].as!FieldType;
            }
            else {
                // If node contains a non-integer value, convert it to a string first and then to the correct type
                __traits(getMember, obj, fieldName) = yamlNode[fieldName].as!string.to!FieldType;
            }
        }
        else static if (isBoolean!FieldType) {
            // Convert to string first, then to the correct boolean type.
            __traits(getMember, obj, fieldName) = yamlNode[fieldName].as!string.to!FieldType;
        }
        else {
            __traits(getMember, obj, fieldName) = yamlNode[fieldName].as!FieldType;
        }
    }
}

/// Deserialize a D-YAML Node into a struct of type T
T deserializeTo(T)(Node yamlNode) if (is(T == struct)) {
    T obj;

    yamlNode.deserializeInto(obj);
    return obj;
}