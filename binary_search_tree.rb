# frozen_string_literal: true

# Node forms the structure of the BST.
class Node
  attr_accessor :data, :left, :right

  def initialize(data, left = nil, right = nil)
    @data = data
    @left = left
    @right = right
  end
end

# Tree holds a Balanced BST and associated methods.
class Tree
  attr_reader :root

  def initialize(array)
    @root = build_tree(array.sort.uniq)
  end

  def build_tree(array, start_index = 0, end_index = array.length - 1)
    return nil if start_index > end_index

    mid = (start_index + end_index) / 2
    root = Node.new(array[mid])
    root.left = build_tree(array, start_index, mid - 1)
    root.right = build_tree(array, mid + 1, end_index)
    root
  end

  def cursor_to_leaf(value)
    cursor = Node.new(@root.data, @root.left, @root.right)
    cursor = value < cursor.data ? cursor.left : cursor.right until cursor.left.nil? && cursor.right.nil?
    cursor
  end

  def insert(value)
    cursor = cursor_to_leaf(value)
    if value < cursor.data
      cursor.left = Node.new(value)
    else
      cursor.right = Node.new(value)
    end
  end

  def delete(root = @root, value)
    # Base case
    return root if root.nil?

    # Recursively look through the BST to find the node to be deleted.
    if root.data > value
      root.left = delete(root.left, value)
      return root
    elsif root.data < value
      root.right = delete(root.right, value)
      return root
    end

    # At this point, root is the node to be deleted.

    if root.left.nil?
      return replace_node(root, root.right)
    elsif root.right.nil?
      return replace_node(root, root.left)
    else
      return replace_with_successor(root)
    end
  end

  def replace_node(origin, replacement)
    origin = nil
    replacement
  end

  def replace_with_successor(root)
    successor_parent = root
    successor = root.right
    until successor.left.nil?
      successor_parent = successor
      successor = successor.left
    end
    if successor_parent != root
      successor_parent.left = successor.right
    else
      successor_parent.right = successor.right
    end

    root.data = successor.data

    successor = nil
    root
  end

  def pretty_print(node = @root, prefix = '', is_left = true)
    pretty_print(node.right, "#{prefix}#{is_left ? '|   ' : '    '}", false) if node.right
    puts "#{prefix}#{is_left ? '└── ' : '┌── '}#{node.data}"
    pretty_print(node.left, "#{prefix}#{is_left ? '    ' : '|   '}", true) if node.left
  end

  def find(value)
    cursor = Node.new(@root.data, @root.left, @root.right)
    until cursor.nil? || cursor.data == value
      cursor = value < cursor.data ? cursor.left : cursor.right
    end
    cursor
  end

  def level_order
    return if @root.nil?

    queue = [@root]
    values = []

    until queue.empty?
      current = queue.shift
      if block_given?
        yield current
      else
        values.push(current.data)
      end
      queue.push(current.left) unless current.left.nil?
      queue.push(current.right) unless current.right.nil?
    end
    return values unless block_given?
  end
end

test = Tree.new([1, 7, 4, 23, 8, 9, 4, 3, 5, 7, 9, 67, 6345, 324])
test.pretty_print
p test.insert(2)
p test.insert(6000)
test.pretty_print
p test.delete(2)
p test.delete(7)
p test.delete(9)
test.pretty_print
p test.delete(67)
test.pretty_print
p test.find(6345)
p test.find(7000)
p test.level_order
p test.level_order { |node| print "#{node.data + 1}:" }
